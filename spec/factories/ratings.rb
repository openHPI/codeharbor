# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    user { build(:user) }
    exercise { build(:codeharbor_exercise) }
    rating { 5 }
  end
end
