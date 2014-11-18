class Api::V1::TransactionsController < Api::ApplicationController
  
  def withdraw
    @account = TransactionAccount.find(params[:account_id])
    @account.subscribe self
    @account.process_transaction(params: params, bus_op: :withdraw)
  end
  
  def deposit
    @account = TransactionAccount.find(params[:account_id])
    @account.subscribe self
    @account.process_transaction(params: params, bus_op: :deposit)
  end
  
  def successful_transaction_event(account, txn)
    @account = account
    @transaction = txn
    render 'transaction', status: :created, location: api_v1_account_transaction_path(@account, @transaction)
  end
  
end