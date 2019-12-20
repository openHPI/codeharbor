# frozen_string_literal: true

FactoryBot.define do
  factory :label do
    sequence(:name) { |n| "Test Label #{n}" }
    label_category { build(:label_category) }
  end
end
