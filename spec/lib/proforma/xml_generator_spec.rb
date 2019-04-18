# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'
require 'proforma/xml_generator'

describe Proforma::XmlGenerator do
  let(:generator) { described_class.new }

  describe 'test complex exercise' do
    let(:exercise) { FactoryBot.create(:complex_exercise) }
    let(:xml) do
      ::Nokogiri::XML(
        generator.generate_xml(exercise)
      ).xpath('/p:task')[0]
    end

    describe 'meta data' do
      it 'has single <p:description> tag which contains description' do
        description = xml.xpath('p:description')
        expect(description.size).to be 1
        expect(description.first.text).to eq exercise.descriptions.first.text
      end

      it 'has single <p:meta-data> tag' do
        metaData = xml.xpath('p:meta-data')
        expect(metaData.size).to be 1
      end

      it 'has <p:meta-data>/<p:title> tag which contains title' do
        title = xml.xpath('p:meta-data/p:title')
        expect(title.size).to be 1
        expect(title.first.text).to eq exercise.title
      end

      context 'when proglangs is queried' do
        let(:proglangs) { xml.xpath('p:proglang') }
        let(:proglang_version) { proglangs.first.xpath('@version') }

        it 'has single tag <p:proglang version="8">java</p:proglang>' do
          expect(proglangs.size).to be 1
          expect(proglangs.text).to eq 'Java'

          expect(proglang_version.size).to be 1
          expect(proglang_version.first.value).to eq '1.8'
        end
      end

      it "has empty <p:submission-restrictions>/<p:file-restriction>/<p:optional filename=''> tag" do
        restrictions = xml.xpath('p:submission-restrictions/p:file-restrictions/p:optional')
        expect(restrictions.size).to be 0
        expect(restrictions.text).to be_empty
      end
    end

    describe 'files' do
      it 'has valid main file' do
        file = xml.xpath('p:files/p:file[@comment="main" and @class="template"]')
        exercise_main_file = exercise.exercise_files.where(role: 'Main File').first
        expect(file.size).to be 1
        expect(file.text).to eq exercise_main_file.content
        expect(file.xpath('@filename').first.value).to eq(exercise_main_file.path + '/' + exercise_main_file.name + '.java')
      end

      it 'has 4 internal files' do
        files = xml.xpath('p:files/p:file[@class="internal"]')
        expect(files.size).to be 4
      end

      context 'when one test file is referenced' do
        let(:test_ref) { xml.xpath('//p:test/p:test-configuration/p:filerefs/p:fileref[1]/@refid').first.value }
        let(:test) { xml.xpath('p:files/p:file[@filename="test.java"]') }

        it 'has one test file referenced by tests' do
          expect(test_ref).not_to be_nil
          expect(test.size).to be 1
          expect(test.xpath('@id').first.value).to eq test_ref
          expect(test.text).to eq exercise.tests.first.content
        end
      end

      context 'when one reference implementation referenced by model solutions' do
        let(:solution_ref) { xml.xpath('//p:model-solution/p:filerefs/p:fileref[1]/@refid').first.value }
        let(:solution) { xml.xpath('p:files/p:file[@filename="solution.java"]') }

        it 'has one reference implementation referenced by model solutions' do
          expect(solution_ref).not_to be_nil
          expect(solution.size).to be 1
          expect(solution.xpath('@id').first.value).to eq solution_ref
          expect(solution.text).to eq generator.model_solution_files.first.content
        end
      end

      it 'has one user defined test' do
        user_test = xml.xpath('p:files/p:file[@filename="user_test.java"]')
        expect(user_test.size).to be 1
      end

      it 'has one regular file' do
        user_test = xml.xpath('p:files/p:file[@filename="explanation.txt"]')
        expect(user_test.size).to be 1
      end
    end
  end

  describe 'files' do
    let(:xml) do
      ::Nokogiri::XML(
        generator.generate_xml(FactoryBot.create(:only_meta_data))
      ).xpath('/p:task')[0]
    end

    context 'no files' do
      it 'contains a single empty <p:files>-tag with an ' do
        filesContainer = xml.xpath('p:files')
        expect(filesContainer.size).to be 1
        allFiles = xml.xpath('*/p:file')
        expect(allFiles.size).to be 1 # Because there has to be at least one file that model-solutions can reference to!
      end
    end

    context 'one Java main file' do
      let(:xml) do
        ::Nokogiri::XML(
          generator.generate_xml(FactoryBot.create(:exercise_with_single_java_main_file))
        ).xpath('/p:task')[0]
      end

      it 'has single /p:files/p:file tag' do
        files = xml.xpath('p:files/p:file')
        expect(files.size).to be 2 # Because there has to be at least one file that model-solutions can reference to!
      end

      it 'p:file tag has class="template"' do
        filesClass = xml.xpath('p:files/p:file/@class').first
        expect(filesClass.value).to eq 'template'
      end

      it 'has attribute id on <p:file>-tag' do
        ids = xml.xpath('p:files/p:file/@id')
        expect(ids.size).to be 2 # Because there has to be at least one file that model-solutions can reference to!
        expect(ids.first.value.size).to be > 0
      end

      it 'has attribute filename on <p:file>-tag with name and extension' do
        file_names = xml.xpath('p:files/p:file/@filename')
        expect(file_names.size).to be 1
        expect(file_names.first.value).to eq 'Main.java'
      end

      it 'has attribute class="template" on <p:file>-tag because it is the main file' do
        file_classes = xml.xpath('p:files/p:file/@class')
        expect(file_classes.size).to be 2 # Because there has to be at least one file that model-solutions can reference to!
        expect(file_classes.first.value).to eq 'template'
      end

      it 'has attribute comment="main" on <p:file>-tag because it is the main file' do
        file_comments = xml.xpath('p:files/p:file/@comment')
        expect(file_comments.size).to be 1
        expect(file_comments.first.value).to eq 'main'
      end

      it '<p:file> contains file contents as plain text ' do
        file_contents = xml.xpath('p:files/p:file/text()')
        expect(file_contents.size).to be 1
        expect(file_contents.first.content).to eq 'public class AsteriksPattern{ public static void main String[] args) { } }'
      end
    end
  end

  describe 'tests' do
    context 'no tests' do
      let(:xml) do
        ::Nokogiri::XML(
          generator.generate_xml(FactoryBot.create(:only_meta_data))
        ).xpath('/p:task')[0]
      end

      it 'contains a single empty <p:tests>-tag' do
        testsContainer = xml.xpath('p:tests')
        expect(testsContainer.size).to be 1
        allTests = xml.xpath('*/p:test')
        expect(allTests.size).to be 0
      end
    end

    context 'single JUnit test file' do
      let(:xml) do
        doc = ::Nokogiri::XML(
          generator.generate_xml(FactoryBot.create(:exercise_with_single_junit_test))
        )
        doc.collect_namespaces
        return doc.xpath('/p:task')[0]
      end

      it 'has single <p:tests>/<p:test> tag' do
        # print(xml)
        tests = xml.xpath('p:tests/p:test')
        expect(tests.size).to be 1
      end

      it '<p:test> contains <p:test-type>unittest</p:test-type>' do
        test_types = xml.xpath('p:tests/p:test/p:test-type/text()')
        expect(test_types.size).to be 1
        expect(test_types.first.content).to eq 'unittest'
      end

      it '<p:test> contains single <p:test-configuration>/<p:filerefs>/<p:fileref> pointing to correct exercise file' do
        refids = xml.xpath('p:tests/p:test/p:test-configuration/p:filerefs/p:fileref/@refid')
        expect(refids.size).to be 1
        refid = refids.first.value
        exercise_file = ExerciseFile.find(refid)
        expect(exercise_file.name).to eq 'SingleJUnitTestFile'
      end

      it '<p:test-configuration> contains single <c:feedback-message> with feedbackmessage' do
        feedback_messages = xml.xpath('p:tests/p:test/p:test-configuration/c:feedback-message/text()')
        expect(feedback_messages.size).to be 1
        expect(feedback_messages.first.content).to eq 'Dude... seriously?'
      end

      pending '<p:fileref> points to a <p:file> that actually exists in markup' do
        refids = xml.xpath('p:tests/p:test/p:test-configuration/p:filerefs/p:fileref/@refid')
        expect(refids.size).to be 1
        filenames = xml.xpath("p:task/p:files/p:file[@id=#{refids.first.value}]/@filename")
        expect(filenames.size).to be 1
        expect(filenames.first.value).to eq 'SingleJUnitTestFile.java'
      end

      it '<p:test> contains single <p:test-configuration>/<u:unittest framework="JUnit">' do
        frameworks = xml.xpath('p:tests/p:test/p:test-configuration/u:unittest/@framework')
        expect(frameworks.size).to be 1
        expect(frameworks.first.value).to eq 'JUnit'
      end
    end

    describe 'model solutions' do
      context 'no model solutions' do
        let(:xml) do
          ::Nokogiri::XML(
            generator.generate_xml(FactoryBot.create(:only_meta_data))
          ).xpath('/p:task')[0]
        end

        it 'contains a single empty <p:model-solutions> tag' do
          model_solutions_container = xml.xpath('p:model-solutions')
          expect(model_solutions_container.size).to be 1
          all_model_solutions = xml.xpath('*/p:model-solution')
          expect(all_model_solutions.size).to be 1 # Because minOccurs = 1
        end
      end

      context 'single model solution file' do
        let(:xml) do
          doc = ::Nokogiri::XML(
            generator.generate_xml(FactoryBot.create(:exercise_with_single_model_solution))
          )
          doc.collect_namespaces
          return doc.xpath('/p:task')[0]
        end

        it 'has single <p:model-solutions>/<p:model-solution> tag' do
          model_solutions = xml.xpath('p:model-solutions/p:model-solution')
          expect(model_solutions.size).to be 1
        end

        it '<p:model-solution> contains single <p:filerefs>/<p:fileref> pointing to correct exercise file' do
          refids = xml.xpath('p:model-solutions/p:model-solution/p:filerefs/p:fileref/@refid')
          expect(refids.size).to be 1
          refid = refids.first.value
          exercise_file = ExerciseFile.find(refid)
          expect(exercise_file.name).to eq 'ModelSolutionFile'
        end

        it '<p:fileref> points to a <p:file> that actually exists in markup' do
          refids = xml.xpath('p:model-solutions/p:model-solution/p:filerefs/p:fileref/@refid')
          expect(refids.size).to be 1
          filenames = xml.xpath("p:files/p:file[@id=#{refids.first.value}]/@filename")
          expect(filenames.size).to be 1
          expect(filenames.first.value).to eq 'ModelSolutionFile.java'
        end
      end
    end
  end
end
