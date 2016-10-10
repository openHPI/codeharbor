FactoryGirl.define do
  factory :user, class: 'User' do
  	sequence(:email) {|n| "test_#{n}@test.de" }
  	sequence(:first_name) {|n| "John_#{n}" }
  	last_name 'Doe'
  	password 'secret'
  end
end