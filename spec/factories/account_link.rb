FactoryBot.define do
  factory :account_link, class: 'AccountLink' do
  	push_url 'test@codecode.de/test'
  	account_name 'John1234'
  end
end