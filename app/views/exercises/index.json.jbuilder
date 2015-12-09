json.array!(@exercises) do |exercise|
  json.extract! exercise, :id, :title, :description, :maxrating, :public
  json.url exercise_url(exercise, format: :json)
end
