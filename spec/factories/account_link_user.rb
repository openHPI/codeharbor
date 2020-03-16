# frozen_string_literal: true

FactoryBot.define do
  factory :account_link_user, class: 'AccountLinkUser' do
    account_link { build(:account_link) }
    user { build(:user) }
  end
end
