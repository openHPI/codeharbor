# frozen_string_literal: true

json.array!(@testing_frameworks) do |testing_framework|
  json.extract! testing_framework, :id, :name
  json.url testing_framework_url(testing_framework, format: :json)
end
