# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    text { 'Messagetext' }
    sender { build(:user) }
    recipient { build(:user) }
  end
end
