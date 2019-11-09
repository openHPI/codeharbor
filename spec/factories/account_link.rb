# frozen_string_literal: true

FactoryBot.define do
  factory :account_link, class: 'AccountLink' do
    push_url { 'codecode.de/test' }
    check_uuid_url { 'codecode.de/check' }
    api_key { '123456' }
    name { 'testlink' }
  end
end
