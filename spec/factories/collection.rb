# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    title { 'Some Collection' }
    description { 'Some Description' }
    visibility_level { :private }
    users { build_list(:user, 1) }
    tasks { build_list(:task, 2) }
  end
end
