FactoryGirl.define do
  factory :only_meta_data, class: 'Exercise' do
  	title 'Some Exercise'
    maxrating 10
    private false
    authors {[FactoryGirl.create(:user), FactoryGirl.create(:user)]}
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      exercise.execution_environment = create(:java_8_execution_environment)
    end
  end

  factory :exercise_with_single_java_main_file, class: 'Exercise' do
    title 'Some Exercise'
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      exercise.execution_environment = create(:java_8_execution_environment)
      create(:single_java_main_file, exercise: exercise)
    end
end

  factory :exercise_with_single_junit_test, class: 'Exercise' do
    title 'Exercises with single JUnit Test'
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      exercise.execution_environment = create(:java_8_execution_environment)
      create(:single_junit_test, exercise: exercise)
    end
  end

  factory :exercise_with_single_model_solution, class: 'Exercise' do
    title 'Exercises with single Model Solution'
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      exercise.execution_environment = create(:java_8_execution_environment)
      create(:model_solution_file, exercise: exercise)
    end
  end

end
