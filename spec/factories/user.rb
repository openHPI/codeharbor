# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'User' do
    sequence(:email) { |n| "test_#{n}@test.de" }
    sequence(:first_name) { |n| "John_#{n}" }
    sequence(:username) { |n| "user_john#{n}" }
    last_name { 'Doe' }
    password { 'secret' }
    email_confirmed { true }
  end

  factory :admin, class: 'User' do
    sequence(:email) { |n| "admin_#{n}@test.de" }
    sequence(:username) { |n| "user_admin#{n}" }
    sequence(:first_name) { |n| "Admin_#{n}" }
    last_name { 'Doe' }
    password { 'secret' }
    email_confirmed { true }
    role { 'admin' }
  end
end
