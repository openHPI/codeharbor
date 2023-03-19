# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    title { 'Some Collection' }
    users { build_list(:user, 1) }
    tasks { build_list(:task, 2) }
  end
end
