# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    exercise { nil }
    user { nil }
    text { 'MyText' }
  end
end
