# frozen_string_literal: true

json.array!(@comments) do |comment|
  json.extract! comment, :id, :text, :exercise_id, :user_id
  json.url comment_url(comment, format: :json)
end
