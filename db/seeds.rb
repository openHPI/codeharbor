# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

exercise = Exercise.create(title: 'test exercise', description: 'this is a test exercise', maxrating: '10', public: true)

ExerciseFile.create(main: true, content: 'public class HelloWorld 
{
 
       public static void main (String[] args)
       {
             System.out.println("Hello World!");
       }
       }', path: '', solution: true, filetype: 'java', exercise: exercise)
ExerciseFile.create(main: true, content: 'public class HelloWorld 
{
 
       public static void main (String[] args)
       {
       }
       }', path: '', solution: false, filetype: 'java', exercise: exercise)

test_framework = TestingFramework.create(name: 'JUnit 4')
Test.create(content: 'Junit test .....', rating: 7, feedback_message: 'Test x failed!', exercise: exercise, testing_framework: test_framework)

user1 = User.create(email: 'test1@test.de', password: 'pwd')
Rating.create(rating: 4, exercise: exercise, user: user1)
user2 = User.create(email: 'test2@test.de', password: 'pwd')
Rating.create(rating: 4, exercise: exercise, user: user2)
user3 = User.create(email: 'test3@test.de', password: 'pwd')
Rating.create(rating: 2, exercise: exercise, user: user3)

comment = Comment.create(text: 'random comment asdklöfjkldöasdfklödf', exercise: exercise, user: user1)
Answer.create(text: 'text text text', comment: comment, user: user2)

AccountLink.create(push_url: 'google.com/pushpush', account_name: 'account1000')

category1 = LabelCategory.create(name: 'Languages')
category2 = LabelCategory.create(name: 'Level')
category3 = LabelCategory.create(name: 'Target Group')
Label.create(name: 'Java', label_category: category1, exercise: exercise)
Label.create(name: 'basic', label_category: category2, exercise: exercise)
Label.create(name: 'pupil', label_category: category3, exercise: exercise)