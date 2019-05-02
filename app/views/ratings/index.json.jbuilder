# frozen_string_literal: true

json.array!(@ratings) do |rating|
  json.extract! rating, :id, :rating, :exercise_id, :user_id
  json.url rating_url(rating, format: :json)
end
