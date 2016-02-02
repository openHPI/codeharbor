# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

exercise = Exercise.create(title: 'test exercise', description: 'this is a test exercise', maxrating: '10', public: true)
ExerciseFile.create(main: true, content: "public class HelloWorld \n{\n  public static void main (String[] args)\n  {\n    System.out.println('Hello World!');\n  }\n}", path: '', solution: true, filetype: 'java', exercise: exercise)
ExerciseFile.create(main: true, content: "public class HelloWorld \n{\n  public static void main (String[] args)\n  {\n  	\n  }\n}", path: '', solution: false, filetype: 'java', exercise: exercise)

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
l1 = Label.create(name: 'Java', color: '006600', label_category: category1)
l2 = Label.create(name: 'basic', color: 'DF0101', label_category: category2)
l3 = Label.create(name: 'pupil', color: '3333CC', label_category: category3)

exercise.labels << l1
exercise.labels << l2
exercise.labels << l3

exercise2 = Exercise.create(title: "Java Einstieg Woche1 ...", description: "In diesem Programm sind zwei Fehler versteckt. Versuche diese zu finden und zu beheben. Anschließend soll das Programm ""Hallo Welt"" ausgeben.\nFinde die beiden Fehler, die wir in das Programm eingebaut haben.", maxrating: '10', public: true)
ExerciseFile.create(main: true, content: "public class HalloWelt {\n    // Hier haben sich zwei Fehler eingeschlichen\n    public static void main (String [] args){\n        System.out.println(Hallo Welt)\n    }\n}", path: '', solution: false, filetype: 'java', exercise: exercise2)
Test.create(content: "import static org.junit.Assert.*;\nimport java.io.ByteArrayOutputStream;\nimport java.io.PrintStream;\nimport org.junit.AfterClass;\nimport org.junit.Before;\nimport org.junit.BeforeClass;\nimport org.junit.Test;\npublic class HalloWeltTest1 {\n    \n    private final static ByteArrayOutputStream outContent = new ByteArrayOutputStream();\n    private static PrintStream old;\n    @BeforeClass\n    public static void setUpStreams() {\n        old = System.out;\n        System.setOut(new PrintStream(outContent));\n    }\n    @AfterClass\n    public static void cleanUpStreams() {\n        System.setOut(old);\n    }\n    \n    @Before\n    public void resetOut(){\n        outContent.reset();\n    }\n    \n    @Test\n    public void testIfErrorFree(){\n        try{\n            HalloWelt.main(new String[] {});\n        }catch (Error e){\n            fail();\n        }\n    }\n    @Test\n    public void testSomething(){\n        assert(true);\n    }\n}", rating: 5, feedback_message: "Es existieren noch Fehler im Programm. Daher kann dieses noch nicht ausgeführt werden", exercise: exercise2, testing_framework: test_framework)
Test.create(content: "import static org.junit.Assert.*;\nimport java.io.ByteArrayOutputStream;\nimport java.io.PrintStream;\nimport org.junit.AfterClass;\nimport org.junit.Before;\nimport org.junit.BeforeClass;\nimport org.junit.Test;\npublic class HalloWeltTest2 {\n    \n    private final static ByteArrayOutputStream outContent = new ByteArrayOutputStream();\n    private static PrintStream old;\n    @BeforeClass\n    public static void setUpStreams() {\n        old = System.out;\n        System.setOut(new PrintStream(outContent));\n    }\n    @AfterClass\n    public static void cleanUpStreams() {\n        System.setOut(old);\n    }\n    \n    @Before\n    public void resetOut(){\n        outContent.reset();\n    }\n    \n    @Test\n    public void checkForCorrectOutput(){\n        HalloWelt.main(new String[] {});\n        String separator = System.getProperty(""line.separator"");\n        assertEquals(""Hallo Welt""+separator, outContent.toString());\n    }\n    @Test\n    public void testSomething(){\n        assert(true);\n    }\n}", rating: 1, feedback_message: "Es wird ein falscher String ausgegeben, erwartet ist die Ausgabe\nHallo Welt", exercise: exercise2, testing_framework: test_framework)

exercise2.labels << l1

