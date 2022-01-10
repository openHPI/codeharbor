# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'User' do
    sequence(:email) { |n| "test_#{n}@test.de" }
    sequence(:first_name) { |n| "John_#{n}" }
    last_name { 'Doe' }
    password { 'secret123' }
    password_confirmation { 'secret123' }
    confirmed_at { Time.zone.now }
  end

  factory :admin, class: 'User' do
    sequence(:email) { |n| "admin_#{n}@test.de" }
    sequence(:first_name) { |n| "Admin_#{n}" }
    last_name { 'Doe' }
    password { 'secret456' }
    password_confirmation { 'secret456' }
    confirmed_at { Time.zone.now }
    role { 'admin' }
  end
end
