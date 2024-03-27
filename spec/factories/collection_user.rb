# frozen_string_literal: true

FactoryBot.define do
  factory :collection_user do
    user
    collection
  end
end
