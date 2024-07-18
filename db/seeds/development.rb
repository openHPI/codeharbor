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

pl_java = ProgrammingLanguage.create!(language: 'Java', version: '17', file_extension: '.java')
pl_python = ProgrammingLanguage.create!(language: 'Python', version: '3.8', file_extension: '.py')

tf_junit = TestingFramework.create!(name: 'JUnit', version: '5')
TestingFramework.create!(name: 'Pytest', version: '6')

task1 = Task.create!(
  title: 'Hello World',
  description: 'Write a simple program that prints "Hello World".',
  internal_description: 'This is a simple exercise for your students to begin with Java.',
  uuid: 'f15cb7a3-87eb-4c4c-a998-c33e25d44cdc',
  language: 'en',
  programming_language: pl_java,
  user: user1,
  meta_data: {
    '@@order': ['meta-data'],
    'meta-data': {
      '@xmlns': {
        CodeOcean: 'codeocean.openhpi.de',
      },
      '@@order': ['CodeOcean:files'],
      'CodeOcean:files': {
        '@@order': ['CodeOcean:CO-42'],
        'CodeOcean:CO-42': {
          '@@order': ['CodeOcean:role'],
          'CodeOcean:role': {
            '$1': 'main_file',
            '@@order': ['$1'],
          },
        },
      },
    },
  },
  submission_restrictions: {
    '@@order' => ['submission-restrictions'],
    'submission-restrictions' => {
      '@@order' => ['file-restriction'],
      '@max-size' => '1400',
      'file-restriction' => {
        '$1' => 'HelloWorld.java',
        '@@order' => ['$1'],
      },
    },
  },
  grading_hints: {
    '@@order' => ['grading-hints'],
    'grading-hints' => {
      'root' => {
        '@@order' => ['test-ref'],
        'test-ref' => [{'@ref' => '2', '@weight' => '1'}],
        '@function' => 'sum',
      },
      '@@order' => ['root'],
    },
  },
  external_resources: {
    '@@order' => %w[external-resources],
    'external-resources' => {
      '@@order' => %w[external-resource],
      '@xmlns' => {'foo' => 'urn:custom:foobar'},
      'external-resource' => [
        {
          '@@order' => %w[internal-description foo:bar],
          '@id' => 'external-resource 1',
          '@reference' => '1',
          '@used-by-grader' => 'true',
          '@visible' => 'delayed',
          '@usage-by-lms' => 'download',
          'internal-description' => {
            '@@order' => %w[$1],
            '$1' => 'internal-desc',
          },
          'foo:bar' => {
            '@@order' => %w[foo:content],
            '@version' => '4',
            'foo:content' => {
              '@@order' => %w[$1],
              '$1' => 'foobar',
            },
          },
        },
      ],
    },
  }
)

TaskFile.create!(
  name: 'HelloWorld.java',
  internal_description: 'The main java file.',
  used_by_grader: true,
  visible: 'yes',
  usage_by_lms: 'edit',
  fileable: task1,
  xml_id: '42',
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
  task: task1,
  testing_framework: tf_junit
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
  name: 'HelloWorldSolution.java',
  mime_type: nil,
  used_by_grader: true,
  visible: 'delayed',
  usage_by_lms: 'display',
  fileable: task1_solution1,
  xml_id: '2',
  content: <<~JAVA)
    public class HelloWorldSolution {
      public static void main (String[] args) {
        System.out.println("Hello World");
      }
    }
  JAVA

TaskFile.create!(
  name: 'Makefile',
  mime_type: nil,
  used_by_grader: true,
  visible: 'no',
  usage_by_lms: 'display',
  fileable: task1,
  xml_id: '3',
  content: <<~MAKEFILE)
    run:
    	@javac -encoding utf8 HelloWorld.java
    	@java -Dfile.encoding=UTF8 HelloWorld
    	#exit

    test:
    	javac -encoding utf8 ${FILENAME}
    	java -jar ${JUNIT} --classpath ${CLASSPATH} --disable-banner --details-theme ascii --disable-ansi-colors --details tree --select-class ${CLASS_NAME}
  MAKEFILE

task2 = Task.create!(
  title: 'Minimal Hello World',
  description: 'Write a simple program that prints "Hello World".',
  internal_description: 'This is a simple exercise for your students to begin with Python.',
  uuid: 'a85825d4-397b-4c65-8550-ae607f0a70e9',
  language: 'en',
  programming_language: pl_python,
  user: user1,
  meta_data: {
    '@@order': [
      'meta-data',
    ],
    'meta-data': {
      '@xmlns': {
        CodeOcean: 'codeocean.openhpi.de',
      },
      '@@order': [
        'CodeOcean:files',
      ],
      'CodeOcean:files': {
        '@@order': [
          'CodeOcean:CO-42',
        ],
        'CodeOcean:CO-42': {
          '@@order': [
            'CodeOcean:role',
          ],
          'CodeOcean:role': {
            '$1': 'main_file',
            '@@order': [
              '$1',
            ],
          },
        },
      },
    },
  }
)

TaskFile.create!(
  name: 'hello_world.py',
  internal_description: 'The main Python file.',
  used_by_grader: true,
  visible: 'yes',
  usage_by_lms: 'edit',
  fileable: task2,
  xml_id: '1337',
  content: <<~PYTHON)
    # print("Hello World")
  PYTHON

Rating.create!(overall_rating: 2, task: task1, user: user2)
Rating.create!(overall_rating: 4, task: task1, user: user4)
Rating.create!(overall_rating: 5, task: task1, user: user3)

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
  description: 'All teachers from openHPI programming courses.',
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
