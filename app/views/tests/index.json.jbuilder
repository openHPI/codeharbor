# frozen_string_literal: true

json.array!(@tests) do |test|
  json.extract! test, :id, :content, :rating, :feedback_message, :testing_framework_id
  json.url test_url(test, format: :json)
end
