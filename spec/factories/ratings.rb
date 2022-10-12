# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    user { build(:user) }
    task { build(:task) }
    rating { 5 }
  end
end
