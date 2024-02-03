# frozen_string_literal: true

FactoryBot.define do
  factory :collection_user_favorite do
    user
    collection
  end
end
