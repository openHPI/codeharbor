# frozen_string_literal: true

FactoryBot.define do
  factory :group_task do
    task { build(:task) }

    trait :with_group do
      group { build(:group) }
    end
  end
end
