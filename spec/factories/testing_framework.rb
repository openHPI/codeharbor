# frozen_string_literal: true

FactoryBot.define do
  factory :testing_framework, aliases: [:junit_testing_framework] do
    name { 'Example Framework' }
    sequence(:version, &:to_s)

    trait :junit do
      name { 'JUnit' }
      version { '5' }
    end

    trait :pytest do
      name { 'Pytest' }
      version { '6' }
    end
  end
end
