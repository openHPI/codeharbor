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
    role { 'Main File' }
  end

  factory :junit_test_file, class: 'ExerciseFile' do
    content { 'public class SingleJUnitTestFile { public static void main String[] args) { } }' }
    name { 'SingleJUnitTestFile' }
    path { '' }
    solution { false }
    file_type { FactoryBot.create(:java_file_type) }
    visibility { true }
  end

  factory :model_solution_file, class: 'ExerciseFile' do
    content { 'public class ModelSolutionFile { public static void main String[] args) { } }' }
    name { 'ModelSolutionFile' }
    path { '' }
    role { 'Reference Implementation' }
    file_type { FactoryBot.create(:java_file_type) }
    visibility { false }
    hidden { false }
    read_only { true }
  end

  factory :codeharbor_regular_file, class: 'ExerciseFile' do
    content { '// Please name a java package for basic input/output operations' }
    name { 'explanation' }
    path { '' }
    role { 'Regular File' }
    file_type { FactoryBot.create(:txt_file_type) }
    hidden { true }
    read_only { true }

    trait(:with_attachment) do
      name { 'image' }
      content {}
      attachment do
        "data:image/bmp;base64,#{Base64.encode64("BM:\u0000\u0000\u0000\u0000\u0000\u0000\u00006\u0000\u0000\u0000(\u0000"\
          "\u0000\u0000\u0001\u0000\u0000\u0000\u0001\u0000\u0000\u0000\u0001\u0000\u0018\u0000\u0000\u0000\u0000\u0000\u0004"\
          "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000"\
          "\u0000\u0000\xFFY")}"
      end
      attachment_file_name { 'image.bmp' }
      attachment_content_type { 'image/bmp' }
      file_type { FactoryBot.create(:bmp_file_type) }
    end
  end

  factory :codeharbor_main_file, class: 'ExerciseFile' do
    content { 'System.x.print("Hello World");' }
    name { 'hello_world' }
    path { 'source/main' }
    role { 'Main File' }
    hidden { false }
    read_only { false }
    file_type { FactoryBot.create(:java_file_type) }
  end

  factory :codeharbor_solution_file, class: 'ExerciseFile' do
    content { 'System.out.print("Hello World");' }
    name { 'solution' }
    path { '' }
    role { 'Reference Implementation' }
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
    file_type { FactoryBot.create(:java_file_type) }
    visibility { true }
    hidden { true }
    read_only { true }
  end
end
