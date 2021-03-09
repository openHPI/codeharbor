# frozen_string_literal: true

FactoryBot.define do
  factory :test, aliases: [:single_junit_test], class: 'Test' do
    title { 'title' }
    sequence(:xml_id) { |n| "test_#{n}" }
  end
end
