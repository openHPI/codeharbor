# frozen_string_literal: true

FactoryBot.define do
  factory :group_task do
    task

    trait :with_group do
      group
    end
  end
end
