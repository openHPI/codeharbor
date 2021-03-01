# frozen_string_literal: true

FactoryBot.define do
  factory :test, aliases: [:single_junit_test], class: 'Test' do
    title { 'title' }
  end

  factory :task_test, class: 'Test' do
    title { 'title' }
  end
end
