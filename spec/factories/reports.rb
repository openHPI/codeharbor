# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    task
    user
    text { 'MyText' }
  end
end
