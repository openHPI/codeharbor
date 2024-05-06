# frozen_string_literal: true

FactoryBot.define do
  factory :account_link_user, class: 'AccountLinkUser' do
    account_link
    user
  end
end
