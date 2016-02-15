FactoryGirl.define do
  factory :only_meta_data, class: 'Exercise' do
  	title 'Some Exercise'
  	description 'Very descriptive'
    maxrating 10
  end

  factory :exercise_with_single_java_main_file, class: 'Exercise' do
    title 'Some Exercise'
  	description 'Very descriptive'
    after(:create) do |exercise|
       create(:single_java_main_file, exercise: exercise)
     end
  end

end
=begin
category1 = LabelCategory.create(name: 'Languages')
l1 = Label.create(name: 'Java', color: '006600', label_category: category1)
test_framework = TestingFramework.create(name: 'JUnit 4')

ExerciseFile.create(main: true, content: "public class AsteriksPattern{ public static void main String[] args) { } }", path: '', solution: false, filetype: 'java', exercise: exercise3)

Test.create(content: "public class AsteriksPattern {
  public static void main(String[] args) {
    printAsterisk();
  }
  static void printAsterisk() {
    System.out.println('*****');
    System.out.println('*****');
    System.out.println('*****');
    System.out.println('*****');
    System.out.println('*****');
  }
}", rating: 5, feedback_message: "Dein Pattern sieht noch nicht wie das Asteriks Pattern aus. Schaue es dir nochmal genauer an!", exercise: exercise3, testing_framework: test_framework)

exercise3.labels << l1

=end
