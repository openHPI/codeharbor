FactoryGirl.define do

  factory :single_junit_test, class: 'Test' do
    feedback_message "Dude... seriously?"
    
    after(:create) do |test|
      create(:junit_testing_framework, tests: [test])
      test_file = create(:junit_test_file)
      test.exercise_file = test_file
      test.save
    end
  end

end
