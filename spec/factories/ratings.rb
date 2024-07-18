# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    user
    task
    Rating::CATEGORIES.each do |category|
      send(category) { 5 }
    end
  end
end
