# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user1 = User.create(first_name: 'Manfred',
                    last_name: 'Anderson',
                    email: 'manfredAnderson@bhak1.de',
                    email_confirmed: true,
                    password: 'pwd',
                    role: 'admin')
user2 = User.create(first_name: 'Johannes',
                    last_name: 'Maier',
                    email: 'j.maier@waldschule.de',
                    email_confirmed: true,
                    password: 'pwd')
user3 = User.create(first_name: 'Denise',
                    last_name: 'Feler',
                    email: 'denise.feler@gmx.de',
                    email_confirmed: true,
                    password: 'pwd')
user4 = User.create(first_name: 'Theresa',
                    last_name: 'Zobel',
                    email: 'theresa.zobel@student.hpi.de',
                    email_confirmed: true,
                    password: '1234')
User.create(first_name: 'Theresa',
            last_name: 'Zobel',
            email: 'theresa.zobel@aon.at',
            email_confirmed: true,
            password: '1234')
User.create(first_name: 'Adrian',
            last_name: 'Steppat',
            email: 'adrian.steppat@student.hpi.de',
            email_confirmed: true,
            password: 'harbor',
            role: 'admin')
User.create(first_name: 'Adrian',
            last_name: 'Steppat',
            email: 'adrian.steppat@web.de',
            email_confirmed: true,
            password: 'harbor')

license1 = License.create(name: 'MIT License', link: 'https://opensource.org/licenses/MIT')
License.create(name: 'Creative Common Attribution', link: 'https://creativecommons.org/licenses/by/4.0/')

Relation.create(name: 'Derivate')
Relation.create(name: 'Translate')
Relation.create(name: 'Port')

category1 = LabelCategory.create(name: 'Languages')
category2 = LabelCategory.create(name: 'Level')
category3 = LabelCategory.create(name: 'Target Group')

l1 = Label.create(name: 'Java', color: '006600', label_category: category1)
l2 = Label.create(name: 'basic-users', color: 'DF0101', label_category: category2)
l3 = Label.create(name: 'pupils', color: '3333CC', label_category: category3)
Label.create(name: 'Python', color: 'FFA500', label_category: category1)

test_framework = TestingFramework.create(name: 'JUnit 4')
TestingFramework.create(name: 'Pytest')

FileType.create(name: 'CSS', file_extension: '.css')
FileType.create(name: 'CoffeeScript', file_extension: '.coffee')
FileType.create(name: 'GIF', file_extension: '.gif')
FileType.create(name: 'HTML', file_extension: '.html')
FileType.create(name: 'Java', file_extension: '.java')
FileType.create(name: 'Jar', file_extension: '.jar')
FileType.create(name: 'JavaScript', file_extension: '.js')
FileType.create(name: 'JPEG', file_extension: '.jpg')
FileType.create(name: 'JSON', file_extension: '.json')
FileType.create(name: 'Makefile', file_extension: '')
FileType.create(name: 'MP3', file_extension: '.mp3')
FileType.create(name: 'MPEG-4', file_extension: '.mp4')
FileType.create(name: 'Ogg Vorbis', file_extension: '.ogg')
FileType.create(name: 'Plain Text', file_extension: '.txt')
FileType.create(name: 'PNG', file_extension: '.png')
FileType.create(name: 'Python', file_extension: '.py')
FileType.create(name: 'Ruby', file_extension: '.rb')
FileType.create(name: 'SQL', file_extension: '.sql')
FileType.create(name: 'SQLite', file_extension: '.sqlite')
FileType.create(name: 'SVG', file_extension: '.svg')
FileType.create(name: 'WebM', file_extension: '.webm')
FileType.create(name: 'XML', file_extension: '.xml')

exercise1 = Exercise.new(title: 'Hello World', maxrating: '10', private: false, user_id: user1.id, license: license1)

exercise1_main = ExerciseFile.create(
  content: 'public class HelloWorld{ public static void main String[] args) { } }',
  name: 'main',
  path: '',
  purpose: 'template',
  visibility: true,
  role: 'main_file',
  hidden: false,
  read_only: false,
  file_type: java_file
)
exercise1.exercise_files << exercise1_main

exercise1_test = ExerciseFile.create(
  content: "public class HelloWorld{ public static void main String[] args) {System.out.println('Hello World.'); } }",
  name: 'test',
  path: '',
  purpose: 'test',
  visibility: true,
  hidden: false,
  read_only: false,
  file_type: java_file,
  exercise: exercise1
)
test = Test.create(
  feedback_message: "Es wird noch nicht 'Hello World' am Bildschrim ausgegeben!",
  exercise_file: exercise1_test,
  testing_framework: test_framework
)
exercise1.tests << test

description1 = Description.create(text: "Schreibe ein Java Programm, das 'Hello World' am Bildschirm ausgibt.", language: 'de')
description2 = Description.create(text: "Write a Java program, which returns and prints 'Hello World'.", language: 'en')
exercise1.descriptions << description1
exercise1.descriptions << description2

ee1 = ExecutionEnvironment.create(language: 'Java', version: '8')
ExecutionEnvironment.create(language: 'Python', version: '3.4')
ExecutionEnvironment.create(language: 'Ruby', version: '2.2')
ExecutionEnvironment.create(language: 'Node.js', version: '')
ExecutionEnvironment.create(language: 'HTML', version: '5')
ExecutionEnvironment.create(language: 'CoffeeScript', version: '2')
ExecutionEnvironment.create(language: 'SQLite', version: '3')

exercise1.execution_environment = ee1
exercise1.save

Rating.create(rating: 4, exercise: exercise1, user: user4)
Rating.create(rating: 2, exercise: exercise1, user: user2)
Rating.create(rating: 5, exercise: exercise1, user: user3)

Comment.create(text: 'This is a nice exercise! Awesome', exercise: exercise1, user: user4)
Comment.create(text: 'Some errors occurred and the description is not that great. ', exercise: exercise1, user: user2)
Comment.create(text: 'Looking forward to show this exercise to my students! Good Work', exercise: exercise1, user: user3)

exercise1.labels << l1
exercise1.labels << l2
exercise1.labels << l3

AccountLink.create(user: user1, push_url: 'google.com/pushpush', api_key: 'abcdefg')
