FactoryBot.define do
  factory :account_link, class: 'AccountLink' do
  	push_url { 'test@codecode.de/test' }
  	account_name { 'John1234' }
    oauth2_token { '123456' }
    client_id { 'd7de7a31-e334-48f4-a32a-c38c9b5057f4' }
    client_secret { '7dceef35d4e418f106a3ca95710f308' }
  end
end
