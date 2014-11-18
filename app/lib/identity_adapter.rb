class IdentityAdapter
  
  include Wisper::Publisher
  
  attr_accessor :access_token, :id_token, :id_token_encoded, :user_proxy
  
  include UrlHelpers
  
  def authorise_url(host: nil, scope: nil)
    q = {}
    q[:response_type] = "code"
    q[:redirect_uri] = url_helpers.authorisation_identities_url host: host
    q[:scope] = scope
    q[:client_id] = Setting.oauth["client_id"]
    "#{Setting.oauth(:id_service_url)}?#{q.to_query}"    
  end
  
  def logout_url(user_proxy: nil, host: nil)
    q = {post_logout_redirect_uri: url_helpers.root_url(host: host)}
    q[:id_token_hint] = user_proxy.access_token["id_token"]
    "#{Setting.oauth(:id_logout_service_url)}?#{q.to_query}"
  end
  
  #POST /token HTTP/1.1
  #   Host: server.example.com
  #   Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
  #   Content-Type: application/x-www-form-urlencoded
  #
  #   grant_type=authorization_code&code=SplxlOBeZQQYbYS6WxSbIA
  #   &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb
  
  def get_access(params: nil, host: nil)
    form = { grant_type: "authorization",
      code: params[:code],
      redirect_uri: url_helpers.authorisation_identities_url(host: host)
    }
    Faraday.new do |c|
      c.use Faraday::Request::BasicAuthentication
    end
    conn = Faraday.new(url: Setting.oauth["id_token_service_url"])
    conn.params = form
    conn.basic_auth Setting.oauth["client_id"], Setting.oauth["client_secret"]
    resp = conn.post
    raise if resp.status >= 300
    @access_token = JSON.parse(resp.body)
    validate_id_token(id_token: @access_token["id_token"])
    @user_proxy = UserProxy.set_up_user(access_token: @access_token, id_token: @id_token)
    if @user_proxy.has_a_kiwi?
      @user_proxy.kiwi.check_party
      publish(:valid_authorisation, @user_proxy)
    else
      publish(:create_a_kiwi, @user_proxy)
    end
  end
  
  def validate_id_token(id_token: nil)
    begin
      @id_token_encoded = id_token      
      @id_token = JWT.decode(@id_token_encoded, Setting.oauth["id_token_secret"]).inject(&:merge)
      self
    rescue JWT::DecodeError => e
      raise
    end
  end
  
  def valid_token(id_token: nil, party_assertion: nil)
    idt = validate_id_token(id_token: id_token)
    true
  end
  
  def id_token_provided?
    @id_token ? true : false
  end
  
  def get_claim(type: nil, key: nil)
    @id_token[type].first {|c| c["ref"] == "party"}
  end
  
  
end