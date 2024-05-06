# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    text { 'Messagetext' }
    sender factory: :user
    recipient factory: :user
  end
end
