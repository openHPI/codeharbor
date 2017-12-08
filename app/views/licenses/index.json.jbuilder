json.array!(@licenses) do |license|
  json.extract! license, :id
  json.url license_url(license, format: :json)
end
