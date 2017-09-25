FactoryGirl.define do
  factory :simple_exercise, class: 'Exercise' do
    sequence(:title) {|n| "Test Exercise #{n}" }
    avg_rating 0
  end

  factory :exercise_with_author, class: 'Exercise' do
    title 'Some Exercise'
    authors {[FactoryGirl.create(:user), FactoryGirl.create(:user)]}
    avg_rating 0
  end

  factory :only_meta_data, class: 'Exercise' do
  	title 'Some Exercise'
    maxrating 10
    avg_rating 0
    private false
    authors {[FactoryGirl.create(:user), FactoryGirl.create(:user)]}
    execution_environment {FactoryGirl.create(:java_8_execution_environment)}
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
    end
  end

  factory :exercise_with_single_java_main_file, class: 'Exercise' do
    title 'Some Exercise'
    avg_rating 0
    execution_environment { FactoryGirl.create(:java_8_execution_environment) }
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      create(:single_java_main_file, exercise: exercise)
    end
  end

  factory :exercise_with_single_junit_test, class: 'Exercise' do
    title 'Exercises with single JUnit Test'
    avg_rating 0
    execution_environment { FactoryGirl.create(:java_8_execution_environment) }
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      create(:single_junit_test, exercise: exercise)
    end
  end

  factory :exercise_with_single_model_solution, class: 'Exercise' do
    title 'Exercises with single Model Solution'
    avg_rating 0
    execution_environment { FactoryGirl.create(:java_8_execution_environment) }
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      create(:model_solution_file, exercise: exercise)
    end
  end

end
