json.kind "accounts"
json.accounts @accounts do |account|
  json.type account.type
  json._links do
    json.self do
      json.href api_v1_account_url(account)
    end
    json.transaction_withdraw do
      json.href withdraw_api_v1_account_transactions_url(account)
    end
    json.transaction_deposit do
      json.href deposit_api_v1_account_transactions_url(account)
    end    
  end
end