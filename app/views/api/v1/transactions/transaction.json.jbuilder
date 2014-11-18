json.kind "transction"
json.bus_op @transaction.bus_op
json.amount @transaction.amount
json._links do
  json.self do
    json.href api_v1_account_transaction_url(@account, @transaction)
  end
  json.transaction_account do
    json.href api_v1_account_url(@account)
  end
end
