FactoryGirl.define do

  factory :single_java_main_file, class: 'ExerciseFile' do
  	main true
    content "public class AsteriksPattern{ public static void main String[] args) { } }"
    file_name 'Main'
    path ''
    solution false
    filetype 'java'
  end

end
