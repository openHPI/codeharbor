# frozen_string_literal: true

FactoryBot.define do
  factory :test, aliases: [:single_junit_test], class: 'Test' do
    feedback_message { 'Dude... seriously?' }

    after(:create) do |test|
      create(:junit_testing_framework, tests: [test])
      test_file = create(:junit_test_file, exercise: test.exercise)
      test.exercise_file = test_file
      test.save
    end
  end

  factory :codeharbor_test, class: 'Test' do
    feedback_message { 'Your solution is not correct yet.' }

    after(:create) do |test|
      create(:junit_testing_framework, tests: [test])
      test_file = create(:codeharbor_test_file, exercise: test.exercise)
      test.exercise_file = test_file
      test.save
    end
  end
end
