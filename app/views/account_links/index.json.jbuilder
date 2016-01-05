json.array!(@account_links) do |account_link|
  json.extract! account_link, :id, :push_url, :account_name
  json.url account_link_url(account_link, format: :json)
end
