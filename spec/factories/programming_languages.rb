# frozen_string_literal: true

FactoryBot.define do
  factory :programming_language do
    trait :ruby do
      language { 'Ruby' }
      version { '3.0.0' }
    end
  end
end
