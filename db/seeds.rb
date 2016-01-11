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
