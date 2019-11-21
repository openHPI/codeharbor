# frozen_string_literal: true

FactoryBot.define do
  factory :label_category do
    sequence(:name) { |n| "Test LabelCategory #{n}" }
  end
end
