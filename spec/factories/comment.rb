# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    text { 'A good comment' }
    task { build(:task) }
    user { build(:user) }
  end
end
