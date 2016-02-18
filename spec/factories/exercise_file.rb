FactoryGirl.define do

  factory :single_java_main_file, class: 'ExerciseFile' do
  	main true
    content "public class AsteriksPattern{ public static void main String[] args) { } }"
    file_name 'Main'
    path ''
    solution false
    file_extension 'java'
    visibility true
  end

  factory :junit_test_file, class: 'ExerciseFile' do
  	main false
    content "public class SingleJUnitTestFile { public static void main String[] args) { } }"
    file_name 'SingleJUnitTestFile'
    path ''
    solution false
    file_extension 'java'
    visibility true
  end

  factory :model_solution_file, class: 'ExerciseFile' do
  	main false
    content "public class ModelSolutionFile { public static void main String[] args) { } }"
    file_name 'ModelSolutionFile'
    path ''
    solution true
    file_extension 'java'
    visibility false
  end

end
