# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    sequence(:title) {|n| "Test Exercise #{n}" }
    description { 'description' }
    user
    uuid { SecureRandom.uuid }
    language { 'de' }

    trait :with_content do
      internal_description { 'internal_description' }
    end

    trait :empty do
      title {}
      description {}
    end

    trait :with_labels do
      labels { build_list(:label, 3) }
    end
  end
end
