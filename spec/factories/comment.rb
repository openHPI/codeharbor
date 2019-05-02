# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    text { 'A good comment' }
    exercise { FactoryBot.create(:simple_exercise) }
    user { FactoryBot.create(:user) }
  end
end
