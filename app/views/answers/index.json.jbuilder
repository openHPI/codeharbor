# frozen_string_literal: true

json.array!(@answers) do |answer|
  json.extract! answer, :id, :comment_id, :user_id
  json.url answer_url(answer, format: :json)
end
