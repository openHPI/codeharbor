# frozen_string_literal: true

FactoryBot.define do
  factory :user_identity do
    user
    omniauth_provider { 'provider' }
    provider_uid { '123456' }
  end
end
