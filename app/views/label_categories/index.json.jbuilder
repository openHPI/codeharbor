json.array!(@label_categories) do |label_category|
  json.extract! label_category, :id, :name
  json.url label_category_url(label_category, format: :json)
end
