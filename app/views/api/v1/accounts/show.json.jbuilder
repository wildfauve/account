json.kind "transaction_account"
json.balance @account.balance
json.type @account.type
json.transactions @account.transactions do |txn|
  json.bus_op txn.bus_op
  json.amount txn.amount
  json.desc txn.desc
end
json._links do
  json.self do
    json.href api_v1_account_url(@account)
  end
  json.party do
    json.href @account.party_url
  end
  
end