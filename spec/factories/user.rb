FactoryGirl.define do
  factory :user, class: 'User' do
  	email 'test@test.de'
  	first_name 'John'
  	last_name 'Doe'
  	password 'secret'
  end
end