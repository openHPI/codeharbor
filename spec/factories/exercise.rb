# frozen_string_literal: true

FactoryBot.define do
  factory :exercise do
    sequence(:title) { |n| "Test Exercise #{n}" }
    descriptions { [FactoryBot.create(:simple_description)] }

    trait :empty do
      title {}
      descriptions { [] }
    end
  end

  factory :simple_exercise, class: 'Exercise' do
    sequence(:title) { |n| "Test Exercise #{n}" }
    descriptions { [FactoryBot.create(:simple_description)] }
  end

  factory :exercise_with_author, class: 'Exercise' do
    title { 'Some Exercise' }
    descriptions { [FactoryBot.create(:simple_description)] }
    authors { [FactoryBot.create(:user), FactoryBot.create(:user)] }
  end

  factory :only_meta_data, class: 'Exercise' do
    title { 'Some Exercise' }
    descriptions { [FactoryBot.create(:simple_description)] }
    maxrating { 10 }

    private { false }

    authors { [FactoryBot.create(:user), FactoryBot.create(:user)] }
    execution_environment { FactoryBot.create(:java_8_execution_environment) }
    license { FactoryBot.create(:license) }
    # after(:create) do |exercise|
    # create(:simple_description, exercise: exercise)
    # end
  end

  factory :exercise_with_single_java_main_file, class: 'Exercise' do
    title { 'Some Exercise' }
    descriptions { [FactoryBot.create(:simple_description)] }
    execution_environment { FactoryBot.create(:java_8_execution_environment) }
    license { FactoryBot.create(:license) }
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      create(:single_java_main_file, exercise: exercise)
    end
  end

  factory :exercise_with_single_junit_test, class: 'Exercise' do
    title { 'Exercises with single JUnit Test' }
    descriptions { [FactoryBot.create(:simple_description)] }
    execution_environment { FactoryBot.create(:java_8_execution_environment) }
    license { FactoryBot.create(:license) }
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      create(:single_junit_test, exercise: exercise)
    end
  end

  factory :exercise_with_single_model_solution, class: 'Exercise' do
    title { 'Exercises with single Model Solution' }
    descriptions { [FactoryBot.create(:simple_description)] }
    execution_environment { FactoryBot.create(:java_8_execution_environment) }
    license { FactoryBot.create(:license) }
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      create(:model_solution_file, exercise: exercise)
    end
  end

  factory :complex_exercise, class: Exercise do
    title { 'Codeharbor Export Test' }
    descriptions { [FactoryBot.create(:codeharbor_description)] }
    execution_environment { FactoryBot.create(:java_8_execution_environment) }
    license { FactoryBot.create(:license) }
    after(:create) do |exercise|
      create(:codeharbor_main_file, exercise: exercise)
      create(:codeharbor_regular_file, exercise: exercise)
      create(:codeharbor_solution_file, exercise: exercise)
      create(:codeharbor_user_test_file, exercise: exercise)
      create(:codeharbor_test, exercise: exercise)
    end
  end
end
