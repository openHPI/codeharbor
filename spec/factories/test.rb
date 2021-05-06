# frozen_string_literal: true

FactoryBot.define do
  factory :test, class: 'Test' do
    title { 'title' }
    sequence(:xml_id) { |n| "test_#{n}" }

    trait :with_content do
      test_type { 'test_type' }
    end
  end
end
