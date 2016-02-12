# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


user1 = User.create(email: 'manfredAnderson@bhak1.de', password: 'pwd')
user2 = User.create(email: 'j.maier@waldschule.de', password: 'pwd')
user3 = User.create(email: 'denise.feler@gmx.de', password: 'pwd')
user4 = User.create(email: 'theresa.zobel@aon.at', password: '1234')
user5 = User.create(email: 'theresa.zobel@student.hpi.de', password: '1234')

category1 = LabelCategory.create(name: 'Languages')
category2 = LabelCategory.create(name: 'Level')
category3 = LabelCategory.create(name: 'Target Group')
l1 = Label.create(name: 'Java', color: '006600', label_category: category1)
l2 = Label.create(name: 'basic-users', color: 'DF0101', label_category: category2)
l3 = Label.create(name: 'pupils', color: '3333CC', label_category: category3)
l4 = Label.create(name: 'Python', color: 'FFA500', label_category: category1)


test_framework = TestingFramework.create(name: 'JUnit 4')
test_framework2 = TestingFramework.create(name: 'Pytest')

exercise1 = Exercise.create(title: "Hello World", description: "Schreibe ein Java Programm, das 'Hello World' am Bildschirm ausgibt.", maxrating: '10', public: true)
ExerciseFile.create(main: true, content: "public class HelloWorld{ public static void main String[] args) { } }", path: '', solution: false, filetype: 'java', exercise: exercise1)
Test.create(content: "public class HelloWorld{ public static void main String[] args) {System.out.println('Hello World.'); } }", rating: 5, feedback_message: "Es wird noch nicht 'Hello World' am Bildschrim ausgegeben!", exercise: exercise1, testing_framework: test_framework)



Rating.create(rating: 4, exercise: exercise1, user: user5)
Rating.create(rating: 2, exercise: exercise1, user: user2)
Rating.create(rating: 5, exercise: exercise1, user: user3)

comment1 = Comment.create(text: 'This is a nice exercise! Awesome', exercise: exercise1, user: user5)
comment2 = Comment.create(text: 'Some errors occurred and the description is not that great. ', exercise: exercise1, user: user2)
comment2 = Comment.create(text: 'Looking forward to show this exercise to my students! Good Work', exercise: exercise1, user: user3)

exercise1.labels << l1
exercise1.labels << l2
exercise1.labels << l3


AccountLink.create(push_url: 'google.com/pushpush', account_name: 'account1000')



exercise2 = Exercise.create(title: "Java Einstieg ", description: "In diesem Programm sind zwei Fehler versteckt. Versuche diese zu finden und zu beheben. Anschließend soll das Programm ""Hallo Welt"" ausgeben.\nFinde die beiden Fehler, die wir in das Programm eingebaut haben.", maxrating: '10', public: true)
ExerciseFile.create(main: true, content: "public class HalloWelt {\n    // Hier haben sich zwei Fehler eingeschlichen\n    public static void main (String [] args){\n        System.out.println(Hallo Welt)\n    }\n}", path: '', solution: false, filetype: 'java', exercise: exercise2)
Test.create(content: "import static org.junit.Assert.*;\nimport java.io.ByteArrayOutputStream;\nimport java.io.PrintStream;\nimport org.junit.AfterClass;\nimport org.junit.Before;\nimport org.junit.BeforeClass;\nimport org.junit.Test;\npublic class HalloWeltTest1 {\n    \n    private final static ByteArrayOutputStream outContent = new ByteArrayOutputStream();\n    private static PrintStream old;\n    @BeforeClass\n    public static void setUpStreams() {\n        old = System.out;\n        System.setOut(new PrintStream(outContent));\n    }\n    @AfterClass\n    public static void cleanUpStreams() {\n        System.setOut(old);\n    }\n    \n    @Before\n    public void resetOut(){\n        outContent.reset();\n    }\n    \n    @Test\n    public void testIfErrorFree(){\n        try{\n            HalloWelt.main(new String[] {});\n        }catch (Error e){\n            fail();\n        }\n    }\n    @Test\n    public void testSomething(){\n        assert(true);\n    }\n}", rating: 5, feedback_message: "Es existieren noch Fehler im Programm. Daher kann dieses noch nicht ausgeführt werden", exercise: exercise2, testing_framework: test_framework)
Test.create(content: "import static org.junit.Assert.*;\nimport java.io.ByteArrayOutputStream;\nimport java.io.PrintStream;\nimport org.junit.AfterClass;\nimport org.junit.Before;\nimport org.junit.BeforeClass;\nimport org.junit.Test;\npublic class HalloWeltTest2 {\n    \n    private final static ByteArrayOutputStream outContent = new ByteArrayOutputStream();\n    private static PrintStream old;\n    @BeforeClass\n    public static void setUpStreams() {\n        old = System.out;\n        System.setOut(new PrintStream(outContent));\n    }\n    @AfterClass\n    public static void cleanUpStreams() {\n        System.setOut(old);\n    }\n    \n    @Before\n    public void resetOut(){\n        outContent.reset();\n    }\n    \n    @Test\n    public void checkForCorrectOutput(){\n        HalloWelt.main(new String[] {});\n        String separator = System.getProperty(""line.separator"");\n        assertEquals(""Hallo Welt""+separator, outContent.toString());\n    }\n    @Test\n    public void testSomething(){\n        assert(true);\n    }\n}", rating: 1, feedback_message: "Es wird ein falscher String ausgegeben, erwartet ist die Ausgabe\nHallo Welt", exercise: exercise2, testing_framework: test_framework)

comment5 = Comment.create(text: 'Gute Übung für Anfänger! mfg Manfred', exercise: exercise2, user: user1)
comment6 = Comment.create(text: 'Meine Schüler fanden die Aufgabe echt toll! Viele Grüße aus der 7b in Buckdeheide!', exercise: exercise2, user: user3)

Rating.create(rating: 5, exercise: exercise2, user: user1)
Rating.create(rating: 5, exercise: exercise2, user: user2)


exercise2.labels << l1
exercise2.labels << l2
exercise2.labels << l3


exercise3 = Exercise.create(title: "Asterisk Pattern", description: "Schreibe ein Java Programm, das das Asterisk Pattern ausgibt. Das Pattern sieht folgendermaßen aus: ***** ***** ***** ***** *****", maxrating: '10', public: true)
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


comment7 = Comment.create(text: 'Sehr schlecht! Pattern unbekannt! Viel Erklärungsaufwand', exercise: exercise3, user: user2)
comment8 = Comment.create(text: 'Mittelmäßig, Schüler waren verwirrd!', exercise: exercise3, user: user3)

Rating.create(rating: 1, exercise: exercise3, user: user1)
Rating.create(rating: 3, exercise: exercise3, user: user2)


exercise3.labels << l1
exercise3.labels << l2
exercise3.labels << l3


exercise4 = Exercise.create(title: "factorial of given numbers", description: "Write a program which can compute the factorial of a given numbers. The results should be printed in a comma-separated sequence on a single line.", maxrating: '10', public: true)
ExerciseFile.create(main: true, content: "def fact(x): return", path: '', solution: false, filetype: 'python', exercise: exercise4)


Test.create(content: "def fact(x):
    if x == 0:
        return 1
    return x * fact(x - 1)

x=int(raw_input())
print fact(x)", rating: 5, feedback_message: "In case of input data being supplied to the question, it should be assumed to be a console input.", exercise: exercise4, testing_framework: test_framework2)


comment9 = Comment.create(text: 'Awesome, nice work!', exercise: exercise4, user: user5)
comment10 = Comment.create(text: 'Great for beginners!', exercise: exercise4, user: user3)

Rating.create(rating: 4, exercise: exercise4, user: user1)
Rating.create(rating: 5, exercise: exercise4, user: user5)

exercise4.labels << l4
exercise4.labels << l2
exercise4.labels << l3

ee1 = ExecutionEnvironment.create(language: 'Java', version: '8')
ee2 = ExecutionEnvironment.create(language: 'Python', version: '2.7')

exercise1.update(execution_environment: ee1)
exercise2.update(execution_environment: ee1)
exercise3.update(execution_environment: ee1)
exercise4.update(execution_environment: ee2)



