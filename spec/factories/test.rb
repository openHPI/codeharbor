# frozen_string_literal: true

FactoryBot.define do
  factory :test, aliases: [:single_junit_test], class: 'Test' do
    feedback_message { 'Dude... seriously?' }
    testing_framework { build(:junit_testing_framework) }
    exercise_file { build(:junit_test_file, exercise: build(:exercise)) }
    exercise { build(:exercise) }
  end

  factory :codeharbor_test, class: 'Test' do
    feedback_message { 'Your solution is not correct yet.' }
    exercise_file { build(:codeharbor_test_file, exercise: build(:exercise)) }
    testing_framework { build(:junit_testing_framework) }
  end

  factory :task_test, class: 'Test' do
    title { 'title' }
  end
end
