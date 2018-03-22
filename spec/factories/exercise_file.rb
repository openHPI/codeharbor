FactoryBot.define do

  factory :single_java_main_file, class: 'ExerciseFile' do
    content "public class AsteriksPattern{ public static void main String[] args) { } }"
    name 'Main'
    path ''
    solution false
    file_type {FactoryBot.create(:java_file_type)}
    visibility true
    role 'Main File'
  end

  factory :junit_test_file, class: 'ExerciseFile' do
    content "public class SingleJUnitTestFile { public static void main String[] args) { } }"
    name 'SingleJUnitTestFile'
    path ''
    solution false
    file_type {FactoryBot.create(:java_file_type)}
    visibility true
  end

  factory :model_solution_file, class: 'ExerciseFile' do
    content "public class ModelSolutionFile { public static void main String[] args) { } }"
    name 'ModelSolutionFile'
    path ''
    role 'Reference Implementation'
    file_type {FactoryBot.create(:java_file_type)}
    visibility false
  end

  factory :codeharbor_regular_file, class: 'ExerciseFile' do
    content "// Please name a java package for basic input/output operations"
    name 'explanation'
    path ''
    role 'Regular File'
    file_type {FactoryBot.create(:txt_file_type)}
  end

  factory :codeharbor_main_file, class: 'ExerciseFile' do
    content 'System.x.print("Hello World");'
    name 'hello_world'
    path 'source/main'
    role 'Main File'
    file_type {FactoryBot.create(:java_file_type)}
  end

  factory :codeharbor_solution_file, class: 'ExerciseFile' do
    content 'System.out.print("Hello World");'
    name 'solution'
    path ''
    role 'Reference Implementation'
    hidden true
    file_type {FactoryBot.create(:java_file_type)}
  end

  factory :codeharbor_user_test_file, class: 'ExerciseFile' do
    content '// Please write a test for your programm'
    name 'user_test'
    path ''
    role 'User-defined Test'
    file_type {FactoryBot.create(:java_file_type)}
  end

  factory :codeharbor_test_file, class: 'ExerciseFile' do
    content 'assert((hello_world.java).equals(solution.java);'
    name 'test'
    path ''
    purpose 'test'
    file_type {FactoryBot.create(:java_file_type)}
    visibility true
  end
end
