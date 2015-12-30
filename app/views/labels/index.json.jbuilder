json.array!(@labels) do |label|
  json.extract! label, :id, :name, :label_category_id
  json.url label_url(label, format: :json)
end
