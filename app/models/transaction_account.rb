class TransactionAccount
  
  include Wisper::Publisher

  include Mongoid::Document
  include Mongoid::Timestamps  
  
  include UrlHelpers
  
  field :type, type: String
  field :sales_product_url, type: String
  field :party_url, type: String
  
  has_many :transactions
  
  def self.get_accounts_with_id_token(params)
    raise if !params[:id_token]
    accounts = self.where(party_url: token_validate_and_extract_claim(id_token: params[:id_token])["link"])
  end
   #{"customer"=>{"_links"=>{"self"=>{"href"=>"http://localhost:3021/api/v1/parties/545964134d6174bb8d050000"}}},"kind"=>"account","sales_product"=>{"_links"=>{"self"=>{"href"=>"http://localhost:3022/api/v1/sales_products/546014564d61745ef6020000"}}, "name"=>"Credit Card"}
  
   def self.token_validate_and_extract_claim(id_token: nil) 
     ia = IdentityAdapter.new.validate_id_token(id_token: id_token)
     ia.get_claim(type: "reference_claims", key: "party")
   end
  
  
  def create_account(account)
    if self.check_not_open(account)
      self.update_attrs(account)
      publish(:successful_add_event, self)
    else
      publish(:account_already_open_event, self)
    end
  end 
  
  def check_not_open(account)
    ac = TransactionAccount.where(party_url: account[:customer][:_links][:self][:href])
            .and(sales_product_url: account[:sales_product][:_links][:self][:href]).first
    ac ? false : true
  end
  
  def update_attrs(account)
    self.type = account[:sales_product][:name]
    self.sales_product_url = account[:sales_product][:_links][:self][:href]
    self.party_url = account[:customer][:_links][:self][:href]
    self.save
  end
  
  def provide_account_summary(options: nil)
    if !options[:id_token]
              binding.pry
      publish(:invalid_summary_event, options.except!(:id_token)) if !options[:id_token]
    else
      if self.class.token_validate_and_extract_claim(id_token: options[:id_token])["link"] != self.party_url
        publish(:invalid_summary_event, options.except!(:id_token))
      else
        publish(:successful_summary_event, self, options.except!(:id_token))
      end
    end
  end
  
  def process_transaction(params: nil, bus_op: nil)
     if self.class.token_validate_and_extract_claim(id_token: params[:id_token])["link"] != self.party_url
       publish(:invalid_transaction_event, self)
     else
       txn = Transaction.add(amount: params[:amount], bus_op: bus_op, desc: params[:desc])
       self.transactions << txn
       self.save
       publish(:successful_transaction_event, self, txn)
     end
  end
  
  def balance
    self.transactions.where(bus_op: :deposit).inject(0) {|ct, t| ct += t.amount} - self.transactions.where(bus_op: :withdraw).inject(0) {|ct, t| ct += t.amount}
  end
  
  def create_account_event
    {
      event: "account_creation",
      timestamps: {
        account_create_time: self.created_at
      },
      sales_product: {
        _links: {
          self: {
            href: self.sales_product_url
          }
        }
      },
      transaction_account: {
        type: self.type,      
        _links: {
          self: {
            href: url_helpers.api_v1_account_url(self, host: Setting.services(:self,:host))
          }
        }        
        
      },
      party: {
        _links: {
          self: {
            href: self.party_url
          }
        }        
      }  
    }
  end
    
end