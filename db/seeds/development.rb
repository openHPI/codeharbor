# frozen_string_literal: true

##### Users #####

user1 = User.new(
  first_name: 'Firstname1',
  last_name: 'Lastname1',
  email: 'user1@example.org',
  password: '12345678',
  password_confirmation: '12345678',
  role: 'admin'
)
user1.skip_confirmation!
user1.save!

user2 = User.new(
  first_name: 'Firstname2',
  last_name: 'Lastname2',
  email: 'user2@example.org',
  password: '12345678',
  password_confirmation: '12345678'
)
user2.skip_confirmation!
user2.save!

user3 = User.new(
  first_name: 'Firstname3',
  last_name: 'Lastname3',
  email: 'user3@example.org',
  password: '12345678',
  password_confirmation: '12345678'
)
user3.skip_confirmation!
user3.save!

user4 = User.new(
  first_name: 'Firstname4',
  last_name: 'Lastname4',
  email: 'user4@example.org',
  password: '12345678',
  password_confirmation: '12345678'
)
user4.skip_confirmation!
user4.save!

AccountLink.create!(
  user: user1,
  name: 'My Autograder',
  push_url: 'http://localhost:7000/import_task',
  check_uuid_url: 'http://localhost:7000/import_uuid_check',
  api_key: 'abcdefg'
)

##### Tasks #####

License.create!(
  name: 'MIT License',
  link: 'https://opensource.org/licenses/MIT'
)
License.create!(
  name: 'Creative Common Attribution',
  link: 'https://creativecommons.org/licenses/by/4.0/'
)

Label.create!(name: 'Loops', color: '006600')
Label.create!(name: 'Conditions', color: 'DF0101')
Label.create!(name: 'Data Structures', color: '3333CC')

pl_java = ProgrammingLanguage.create!(language: 'Java', version: '17')
ProgrammingLanguage.create!(language: 'Python', version: '3')

TestingFramework.create!(name: 'JUnit', version: '5')
TestingFramework.create!(name: 'Pytest', version: '6')

task1 = Task.create!(
  title: 'Hello World',
  description: 'Write a simple program that prints "Hello World".',
  internal_description: 'This is a simple exercise for your students to begin with Java.',
  uuid: 'f15cb7a3-87eb-4c4c-a998-c33e25d44cdc',
  language: 'English',
  programming_language: pl_java,
  user: user1
)

TaskFile.create!(
  name: 'Main.java',
  internal_description: 'The main java file.',
  used_by_grader: true,
  visible: 'yes',
  usage_by_lms: 'edit',
  fileable: task1,
  xml_id: '0',
  content: <<~JAVA)
    public class HelloWorld {
      public static void main (String[] args) {
        // System.out.println("Hello World");
      }
    }
  JAVA

task1_test1 = Test.create!(
  title: 'Output Test',
  description: 'This test checks the output.',
  test_type: 'Unit',
  xml_id: '123456',
  validity: '1',
  timeout: '30',
  task: task1
)

TaskFile.create!(
  name: 'HelloWorldTest.java',
  used_by_grader: true,
  visible: 'no',
  usage_by_lms: 'display',
  fileable: task1_test1,
  xml_id: '1',
  content: <<~JAVA)
    import org.junit.jupiter.api.*;
    import java.io.*;

    public class HelloWorldTest {

        private final static ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        private static PrintStream old;

        @BeforeAll
        public static void setUpStreams() {
            old = System.out;
            System.setOut(new PrintStream(outContent));
        }

        @AfterAll
        public static void cleanUpStreams() {
            System.setOut(old);
        }

        @BeforeEach
        public void resetOut() {
            outContent.reset();
        }

        @Test
        public void checkForCorrectOutput() {
            HelloWorld.main(new String[]{});
            String separator = System.getProperty("line.separator");
            Assertions.assertEquals("hello world" + separator,
                    outContent.toString().toLowerCase(),
                    "Your program does not generate the expected output");
        }
    }
  JAVA

task1_solution1 = ModelSolution.create!(
  description: 'The most simple solution.',
  xml_id: '789',
  task: task1
)

TaskFile.create!(
  name: 'Main.java',
  mime_type: nil,
  used_by_grader: true,
  visible: 'delayed',
  usage_by_lms: 'display',
  fileable: task1_solution1,
  xml_id: '2',
  content: <<~JAVA)
    public class HelloWorld {
      public static void main (String[] args) {
        System.out.println("Hello World");
      }
    }
  JAVA

Rating.create!(rating: 2, task: task1, user: user2)
Rating.create!(rating: 4, task: task1, user: user4)
Rating.create!(rating: 5, task: task1, user: user3)

Comment.create!(text: 'Some errors occurred and the description is not that great.', task: task1, user: user2)
Comment.create!(text: 'Looking forward to show this exercise to my students! Good Work', task: task1, user: user3)
Comment.create!(text: 'This is a nice exercise! Awesome', task: task1, user: user4)

##### Collections #####

collection = Collection.new(title: 'Basic Java Exercises')

collection.users << user1
collection.users << user2

collection.tasks << task1

collection.save!

##### Groups #####
group = Group.new({
                    name: 'openHPI Teachers',
                    description: 'All teachers from openHPI programming courses.'
                  })
group.group_memberships << GroupMembership.new(user: user1, role: :admin)
group.save!
group.add(user2, role: 'confirmed_member')
group.tasks << task1

##### Messages #####

Message.create!(
  text: 'Hi there!',
  sender: user1,
  recipient: user2
)
