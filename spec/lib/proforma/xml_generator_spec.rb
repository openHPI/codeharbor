# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'
require 'proforma/xml_generator'

describe Proforma::XmlGenerator do
  let(:generator) { described_class.new }

  describe '#generate_xml' do
    let(:exercise) { FactoryBot.create(:complex_exercise) }
    let(:xml) do
      ::Nokogiri::XML(
        generator.generate_xml(exercise)
      ).xpath('/p:task')[0]
    end

    describe 'meta data' do
      it 'has single <p:description> tag ' do
        expect(xml.xpath('p:description').size).to be 1
      end

      it 'has <p:description> tag which contains description' do
        expect(xml.xpath('p:description').first.text).to eq exercise.descriptions.first.text
      end

      it 'has single <p:meta-data> tag' do
        expect(xml.xpath('p:meta-data').size).to be 1
      end

      it 'has single <p:meta-data>/<p:title> tag' do
        expect(xml.xpath('p:meta-data/p:title').size).to be 1
      end

      it 'has <p:meta-data>/<p:title> tag which contains title' do
        expect(xml.xpath('p:meta-data/p:title').first.text).to eq exercise.title
      end

      context 'when proglangs is queried' do
        let(:proglangs) { xml.xpath('p:proglang') }
        let(:proglang_version) { proglangs.first.xpath('@version') }

        it 'has single tag <p:proglang version="8">java</p:proglang> with correct content' do
          expect(proglangs).to have_attributes(size: 1, text: 'Java')
        end

        it 'has single tag <p:proglang version="8">java</p:proglang> with correct attribute' do
          expect(proglang_version).to have_attributes(size: 1, text: '1.8')
        end
      end

      it "has empty <p:submission-restrictions>/<p:file-restriction>/<p:optional filename=''> tag" do
        expect(xml.xpath('p:submission-restrictions/p:file-restrictions/p:optional')).to have_attributes(size: 0, text: be_empty)
      end
    end

    context 'when import source has a valid main file' do
      let(:file) { xml.xpath('p:files/p:file[@comment="main" and @class="template"]') }
      let(:exercise_main_file) { exercise.exercise_files.where(role: 'Main File').first }

      it 'has one file with correct content' do
        expect(file).to have_attributes(size: 1, text: exercise_main_file.content)
      end

      it 'has correct filename' do
        expect(file.xpath('@filename').first.value).to eq(exercise_main_file.path + '/' + exercise_main_file.name + '.java')
      end
    end

    it 'has 4 internal files' do
      expect(xml.xpath('p:files/p:file[@class="internal"]').size).to be 4
    end

    context 'when one test file is referenced' do
      let(:test_ref) { xml.xpath('//p:test/p:test-configuration/p:filerefs/p:fileref[1]/@refid').first.value }
      let(:test) { xml.xpath('p:files/p:file[@filename="test.java"]') }

      it 'sets file ref of test' do
        expect(test_ref).not_to be_nil
      end

      it 'sets correct attributes for test' do
        expect(test).to have_attributes(size: 1, text: exercise.tests.first.content)
      end

      it 'has one test file referenced by tests' do
        expect(test.xpath('@id').first.value).to eq test_ref
      end
    end

    context 'when one reference implementation referenced by model solutions' do
      let(:solution_ref) { xml.xpath('//p:model-solution/p:filerefs/p:fileref[1]/@refid').first.value }
      let(:solution) { xml.xpath('p:files/p:file[@filename="solution.java"]') }

      it 'sets file ref of solution' do
        expect(solution_ref).not_to be_nil
      end

      it 'sets correct attributes for solution' do
        expect(solution).to have_attributes(size: 1, text: generator.model_solution_files.first.content)
      end

      it 'has one reference implementation referenced by model solutions' do
        expect(solution.xpath('@id').first.value).to eq solution_ref
      end
    end

    it 'has one user defined test' do
      expect(xml.xpath('p:files/p:file[@filename="user_test.java"]').size).to be 1
    end

    it 'has one regular file' do
      expect(xml.xpath('p:files/p:file[@filename="explanation.txt"]').size).to be 1
    end

    context 'when exercises contains a single Java main file' do
      let(:exercise) { create(:exercise_with_single_java_main_file) }
      let(:ids) { xml.xpath('p:files/p:file/@id') }
      let(:file_names) { xml.xpath('p:files/p:file/@filename') }
      let(:file_classes) { xml.xpath('p:files/p:file/@class') }
      let(:file_comments) { xml.xpath('p:files/p:file/@comment') }
      let(:file_contents) { xml.xpath('p:files/p:file/text()') }

      it 'has single /p:files/p:file tag' do
        expect(xml.xpath('p:files/p:file').size).to be 2 # Because there has to be at least one file that model-solutions can reference to
      end

      it 'p:file tag has class="template"' do
        expect(xml.xpath('p:files/p:file/@class').first.value).to eq 'template'
      end

      it 'has attribute id on <p:file>-tag' do
        expect(ids.first.value.size).to be > 0
      end

      it 'has two ids on <p:file>-tags in total' do
        expect(ids.size).to be 2 # Because there has to be at least one file that model-solutions can reference to!
      end

      it 'has attribute filename on <p:file>-tag with name and extension' do
        expect(file_names.first.value).to eq 'Main.java'
      end

      it 'has a single filename on <p:file>-tag ' do
        expect(file_names.size).to be 1
      end

      it 'has attribute class="template" on <p:file>-tag because it is the main file' do
        expect(file_classes.first.value).to eq 'template'
      end

      it 'has two attributes class="template" on <p:file>-tag in total' do
        expect(file_classes.size).to be 2 # Because there has to be at least one file that model-solutions can reference to!
      end

      it 'has attribute comment="main" on <p:file>-tag because it is the main file' do
        expect(file_comments.first.value).to eq 'main'
      end

      it 'has a single comment="main" on <p:file>-tag' do
        expect(file_comments.size).to be 1
      end

      it '<p:file> contains file contents as plain text ' do
        expect(file_contents.first.content).to eq 'public class AsteriksPattern{ public static void main String[] args) { } }'
      end

      it 'has a single <p:file>-contents' do
        expect(file_contents.size).to be 1
      end
    end

    context 'when exercise only contains meta data' do
      let(:exercise) { create(:only_meta_data) }

      it 'contains a single <p:files>-tag' do
        expect(xml.xpath('p:files').size).to be 1
      end

      it 'contains a single <p:file>-tag' do
        expect(xml.xpath('*/p:file').size).to be 1 # Because there has to be at least one file that model-solutions can reference to!
      end

      it 'contains a single empty <p:tests>-tag' do
        expect(xml.xpath('p:tests').size).to be 1
      end

      it 'contains no <p:test>-tag' do
        expect(xml.xpath('*/p:test').size).to be 0
      end

      it 'contains a single empty <p:model-solutions> tag' do
        expect(xml.xpath('p:model-solutions').size).to be 1
      end

      it 'contains a single empty <p:model-solution> tag' do
        expect(xml.xpath('*/p:model-solution').size).to be 1 # Because minOccurs = 1
      end
    end

    context 'when exercise contains a single JUnit test file' do
      let(:exercise) { create(:exercise_with_single_junit_test) }

      let(:exercise_file) { ExerciseFile.find(refids.first.value) }
      let(:feedback_messages) { xml.xpath('p:tests/p:test/p:test-configuration/c:feedback-message/text()') }
      let(:filenames) { xml.xpath("p:task/p:files/p:file[@id=#{refids.first.value}]/@filename") }
      let(:frameworks) { xml.xpath('p:tests/p:test/p:test-configuration/u:unittest/@framework') }
      let(:refids) { xml.xpath('p:tests/p:test/p:test-configuration/p:filerefs/p:fileref/@refid') }
      let(:test_types) { xml.xpath('p:tests/p:test/p:test-type/text()') }

      it 'has single <p:tests>/<p:test> tag' do
        expect(xml.xpath('p:tests/p:test').size).to be 1
      end

      it '<p:test> contains <p:test-type>unittest</p:test-type>' do
        expect(test_types.first.content).to eq 'unittest'
      end

      it '<p:test> contains a single <p:test-type>' do
        expect(test_types.size).to be 1
      end

      it '<p:test> contains single <p:test-configuration>/<p:filerefs>/' do
        expect(refids.size).to be 1
      end

      it '<p:fileref> pointing to correct exercise file' do
        expect(exercise_file.name).to eq 'SingleJUnitTestFile'
      end

      it '<p:test-configuration> contains <c:feedback-message> with feedbackmessage' do
        expect(feedback_messages.first.content).to eq 'Dude... seriously?'
      end

      it '<p:test-configuration> contains single <c:feedback-message> ' do
        expect(feedback_messages.size).to be 1
      end

      it '<p:test> contains <p:test-configuration>/<u:unittest framework="JUnit">' do
        expect(frameworks.first.value).to eq 'JUnit'
      end

      it '<p:test> contains single <p:test-configuration>/<u:unittest>' do
        expect(frameworks.size).to be 1
      end

      # pending '<p:fileref> points to a <p:file> that actually exists in markup' do
      #   expect(refids.size).to be 1
      #   expect(filenames.size).to be 1
      #   expect(filenames.first.value).to eq 'SingleJUnitTestFile.java'
      # end
    end

    context 'single model solution file' do
      let(:exercise) { create(:exercise_with_single_model_solution) }
      let(:refids) { xml.xpath('p:model-solutions/p:model-solution/p:filerefs/p:fileref/@refid') }
      let(:filenames) { xml.xpath("p:files/p:file[@id=#{refids.first.value}]/@filename") }

      it 'has single <p:model-solutions>/<p:model-solution> tag' do
        expect(xml.xpath('p:model-solutions/p:model-solution').size).to be 1
      end

      it '<p:model-solution> contains single <p:filerefs>/<p:fileref> pointing to correct exercise file' do
        expect(ExerciseFile.find(refids.first.value).name).to eq 'ModelSolutionFile'
      end

      it '<p:fileref> points to a <p:file> that actually exists in markup' do
        expect(filenames.first.value).to eq 'ModelSolutionFile.java'
      end

      it '<p:fileref> points to exactly one <p:file>' do
        expect(filenames.size).to be 1
      end
    end
  end
end
