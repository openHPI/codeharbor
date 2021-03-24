# frozen_string_literal: true

FactoryBot.define do
  factory :model_solution do
    sequence(:xml_id) { |n| "ms_#{n}" }
    description { 'description' }
    internal_description { 'internal_description' }
  end
end
