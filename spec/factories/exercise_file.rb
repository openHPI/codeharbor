FactoryGirl.define do

  factory :single_java_main_file, class: 'ExerciseFile' do
    content "public class AsteriksPattern{ public static void main String[] args) { } }"
    name 'Main'
    path ''
    solution false
    file_type {FactoryGirl.create(:file_type)}
    visibility true
    role 'Main File'
  end

  factory :junit_test_file, class: 'ExerciseFile' do
    content "public class SingleJUnitTestFile { public static void main String[] args) { } }"
    name 'SingleJUnitTestFile'
    path ''
    solution false
    file_type {FactoryGirl.create(:file_type)}
    visibility true
  end

  factory :model_solution_file, class: 'ExerciseFile' do
    content "public class ModelSolutionFile { public static void main String[] args) { } }"
    name 'ModelSolutionFile'
    path ''
    solution true
    file_type {FactoryGirl.create(:file_type)}
    visibility false
  end

end
