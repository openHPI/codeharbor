# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    user
    task
    Rating::CATEGORIES.each do |category|
      send(category) { 3 }
    end

    trait :bad do
      Rating::CATEGORIES.each do |category|
        send(category) { 1 }
      end
    end

    trait :good do
      Rating::CATEGORIES.each do |category|
        send(category) { 5 }
      end
    end
  end
end
