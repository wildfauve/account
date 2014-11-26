class Api::V1::AccountsController < Api::ApplicationController
  
  # called with an ID Token to determine who the accounts are for
  def index
    @accounts = TransactionAccount.get_accounts_with_id_token(params)
  end
  
  def create
    ta = TransactionAccount.new
    ta.subscribe(self)
    ta.create_account(params)
  end
  
  def show
    @account = TransactionAccount.find(params[:id])
    @account.subscribe(self)
    @account.provide_account_summary(options: params.except!(:id))
  end
  
  def update
    @account = TransactionAccount.find(params[:id])
    if params[:reset].present?
      @account.transactions.delete_all
      @account.delete
    end
    render status: :ok
  end
  
  def successful_summary_event(account, options)
    @account = account
    @options = options
    respond_to do |f|
      f.json
      f.js
    end
  end
  
  def invalid_summary_event(options)
    @options = options
    @error = true    
    respond_to do |f|
      f.json {render 'api/v1/shared/error', status: :unprocessable_entity, locals: {status: :unprocessable_entity, message: "Invalid Request"}} 
      f.js
    end
  end
  
  def successful_update_event()
  end
  
  def successful_add_event(ta)
    @ta = ta
    render status: :created
  end

  def account_already_open_event(ta)
    render 'api/v1/shared/error', status: :unprocessable_entity, locals: {status: :account_already_open, message: "account already open"}
  end
  
  
end