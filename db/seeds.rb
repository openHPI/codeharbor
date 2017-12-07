# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


user1 = User.create(first_name: 'Manfred', last_name: 'Anderson', email: 'manfredAnderson@bhak1.de', password: 'pwd', role: 'admin')
user2 = User.create(first_name: 'Johannes', last_name: 'Maier', email: 'j.maier@waldschule.de', password: 'pwd')
user3 = User.create(first_name: 'Denise', last_name: 'Feler', email: 'denise.feler@gmx.de', password: 'pwd')
user4 = User.create(first_name: 'Theresa', last_name: 'Zobel', email: 'theresa.zobel@aon.at', password: '1234')
user5 = User.create(first_name: 'Theresa', last_name: 'Zobel', email: 'theresa.zobel@student.hpi.de', password: '1234')
user6 = User.create(first_name: 'Adrian', last_name: 'Steppat', email: 'adrian.steppat@student.hpi.de', password: 'harbor', role: 'admin')
user7 = User.create(first_name: 'Adrian', last_name: 'Steppat', email: 'adrian.steppat@web.de', password: 'harbor')

license1 = License.create(name: 'MIT License', link: 'https://opensource.org/licenses/MIT')
license2 = License.create(name: 'Creative Common Attribution', link: 'https://creativecommons.org/licenses/by/4.0/')

relation1 = Relation.create(name: 'Derivate')
relation2 = Relation.create(name: 'Translate')
relation3 = Relation.create(name: 'Port')

category1 = LabelCategory.create(name: 'Languages')
category2 = LabelCategory.create(name: 'Level')
category3 = LabelCategory.create(name: 'Target Group')

l1 = Label.create(name: 'Java', color: '006600', label_category: category1)
l2 = Label.create(name: 'basic-users', color: 'DF0101', label_category: category2)
l3 = Label.create(name: 'pupils', color: '3333CC', label_category: category3)
l4 = Label.create(name: 'Python', color: 'FFA500', label_category: category1)


test_framework = TestingFramework.create(name: 'JUnit 4')
test_framework2 = TestingFramework.create(name: 'Pytest')

java_file = FileType.create(name: 'CSS', file_extension: '.css')
coffee_file = FileType.create(name: 'CoffeeScript', file_extension: '.java')
gif_file = FileType.create(name: 'GIF', file_extension: '.coffee')
html_file = FileType.create(name: 'HTML', file_extension: '.html')
java_file = FileType.create(name: 'Java', file_extension: '.java')
jar_file = FileType.create(name: 'Jar', file_extension: '.jar')
js_file = FileType.create(name: 'JavaScript', file_extension: '.js')
jpg_file = FileType.create(name: 'JPEG', file_extension: '.jpg')
json_file = FileType.create(name: 'JSON', file_extension: '.json')
make_file = FileType.create(name: 'Makefile', file_extension: '')
mp3_file = FileType.create(name: 'MP3', file_extension: '.mp3')
mp4_file = FileType.create(name: 'MPEG-4', file_extension: '.mp4')
ogg_file = FileType.create(name: 'Ogg Vorbis', file_extension: '.ogg')
text_file = FileType.create(name: 'Plain Text', file_extension: '.txt')
png_file = FileType.create(name: 'PNG', file_extension: '.png')
python_file = FileType.create(name: 'Python', file_extension: '.py')
ruby_file = FileType.create(name: 'Ruby', file_extension: '.rb')
sql_file = FileType.create(name: 'SQL', file_extension: '.sql')
sqlite_file = FileType.create(name: 'SQLite', file_extension: '.sqlite')
svg_file = FileType.create(name: 'SVG', file_extension: '.svg')
webm_file = FileType.create(name: 'WebM', file_extension: '.webm')
xml_file = FileType.create(name: 'XML', file_extension: '.xml')

exercise1 = Exercise.create(title: "Hello World", maxrating: '10', private: false, user_id:user1.id, license: license1)
exercise1_main = ExerciseFile.create(content: "public class HelloWorld{ public static void main String[] args) { } }", path: '', purpose:'template', visibility: true, role: 'Main File', hidden: false, read_only: false, file_type: java_file, exercise: exercise1)
exercise1_test = ExerciseFile.create(content: "public class HelloWorld{ public static void main String[] args) {System.out.println('Hello World.'); } }", path: '', purpose:'test', visibility: true, role: 'Main File', hidden: false, read_only: false, file_type: java_file, exercise: exercise1)
Test.create(feedback_message: "Es wird noch nicht 'Hello World' am Bildschrim ausgegeben!", exercise_file: exercise1_test, exercise: exercise1, testing_framework: test_framework)

Description.create(text:"Schreibe ein Java Programm, das 'Hello World' am Bildschirm ausgibt.", language: 'de', exercise: exercise1)
Description.create(text:"Write a Java program, which returns and prints 'Hello World'.", language: 'en', exercise: exercise1)


Rating.create(rating: 4, exercise: exercise1, user: user5)
Rating.create(rating: 2, exercise: exercise1, user: user2)
Rating.create(rating: 5, exercise: exercise1, user: user3)

comment1 = Comment.create(text: 'This is a nice exercise! Awesome', exercise: exercise1, user: user5)
comment2 = Comment.create(text: 'Some errors occurred and the description is not that great. ', exercise: exercise1, user: user2)
comment2 = Comment.create(text: 'Looking forward to show this exercise to my students! Good Work', exercise: exercise1, user: user3)

exercise1.labels << l1
exercise1.labels << l2
exercise1.labels << l3

exercise1.descriptions


AccountLink.create(push_url: 'google.com/pushpush', account_name: 'account1000')

ee1 = ExecutionEnvironment.create(language: 'Java', version: '8')
ee2 = ExecutionEnvironment.create(language: 'Python', version: '2.7')

exercise1.update(execution_environment: ee1)

