# frozen_string_literal: true

FactoryBot.define do
  factory :exercise_file, aliases: [:single_java_main_file], class: 'ExerciseFile' do
    content { 'public class AsteriksPattern{ public static void main String[] args) { } }' }
    name { 'Main' }
    path { '' }
    solution { false }
    file_type { build(:java_file_type) }
    visibility { true }
    hidden { false }
    read_only { false }
    role { 'main_file' }
    exercise { build(:exercise) }
  end

  factory :junit_test_file, class: 'ExerciseFile' do
    content { 'public class SingleJUnitTestFile { public static void main String[] args) { } }' }
    name { 'SingleJUnitTestFile' }
    path { '' }
    solution { false }
    file_type { FactoryBot.create(:java_file_type) }
    hidden { false }
    read_only { false }
    visibility { true }
  end

  factory :model_solution_file, class: 'ExerciseFile' do
    content { 'public class ModelSolutionFile { public static void main String[] args) { } }' }
    name { 'ModelSolutionFile' }
    path { '' }
    role { 'reference_implementation' }
    file_type { FactoryBot.create(:java_file_type) }
    visibility { false }
    hidden { false }
    read_only { true }
  end

  factory :codeharbor_regular_file, class: 'ExerciseFile' do
    content { '// Please name a java package for basic input/output operations' }
    name { 'explanation' }
    path { '' }
    role { 'regular_file' }
    file_type { FactoryBot.create(:txt_file_type) }
    hidden { true }
    read_only { true }
    exercise { build(:exercise) }

    trait(:with_attachment) do
      name { 'image' }
      content {}
      file_type { FactoryBot.create(:bmp_file_type) }
      after(:build) do |exercise_file|
        exercise_file.attachment.attach(io: File.open('spec/fixtures/files/red.bmp'), filename: 'red.bmp', content_type: 'image/bmp')
      end
    end

    trait(:with_text_attachment) do
      name { 'text' }
      content {}
      file_type { FactoryBot.create(:txt_file_type) }
      after(:build) do |exercise_file|
        exercise_file.attachment.attach(io: File.open('spec/fixtures/files/example-filename.txt'),
                                        filename: 'example-filename.txt',
                                        content_type: 'text/plain')
      end
    end

    trait :with_image_attachment do
      with_attachment
    end
  end

  factory :codeharbor_main_file, class: 'ExerciseFile' do
    content { 'System.x.print("Hello World");' }
    name { 'hello_world' }
    path { 'source/main' }
    role { 'main_file' }
    hidden { false }
    read_only { false }
    file_type { FactoryBot.create(:java_file_type) }
  end

  factory :codeharbor_solution_file, class: 'ExerciseFile' do
    content { 'System.out.print("Hello World");' }
    name { 'solution' }
    path { '' }
    role { 'reference_implementation' }
    hidden { false }
    read_only { true }
    file_type { FactoryBot.create(:java_file_type) }
  end

  factory :codeharbor_user_test_file, class: 'ExerciseFile' do
    content { '// Please write a test for your programm' }
    name { 'user_test' }
    path { '' }
    role { 'User-defined Test' }
    hidden { false }
    read_only { false }
    file_type { FactoryBot.create(:java_file_type) }
  end

  factory :codeharbor_test_file, class: 'ExerciseFile' do
    content { 'assert((hello_world.java).equals(solution.java);' }
    name { 'test' }
    path { '' }
    purpose { 'test' }
    file_type { build(:java_file_type) }
    visibility { true }
    hidden { true }
    read_only { true }
    role { 'teacher_defined_test' }
  end
end
