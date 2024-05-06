# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    user
    task
    rating { 5 }
  end
end
