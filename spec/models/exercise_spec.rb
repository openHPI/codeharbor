require 'rails_helper'
require 'nokogiri'

RSpec.describe Exercise, type: :model do

  describe '#to_proforma_xml' do

    describe 'meta data' do

      context 'only title, description, maxrating' do
        let(:xml) {
          ::Nokogiri::XML(
            FactoryGirl.create(:only_meta_data).to_proforma_xml
          ).xpath('/root')[0]
        }

        it 'has single <p:description> tag which contains description' do
          descriptions = xml.xpath('p:task/p:description/text()')
          expect(descriptions.size()).to be 1
          expect(descriptions[0].content).to eq 'Very descriptive'
        end

        it 'has single <p:grading-hints> with attribute max-rating="max rating"' do
          maxRatings = xml.xpath('p:task/p:grading-hints/@max-rating')
          expect(maxRatings.size()).to be 1
          expect(maxRatings[0].content).to eq '10'
        end

        it 'has single <p:meta-data> tag' do
          metaData = xml.xpath('p:task/p:meta-data')
          expect(metaData.size()).to be 1
        end

        it 'has <p:meta-data>/<p:title> tag which contains title' do
          titles = xml.xpath('p:task/p:meta-data/p:title/text()')
          expect(titles.size()).to be 1
          expect(titles[0].content).to eq 'Some Exercise'
        end

        it 'has single tag <p:proglang version="1.8">java</p:proglang>' do
          proglangs = xml.xpath('p:task/p:proglang')
          expect(proglangs.size()).to be 1

          proglang_text = proglangs.first.xpath('text()')
          expect(proglang_text.size()).to be 1
          expect(proglang_text.first.content).to eq 'java'

          proglang_version = proglangs.first.xpath('@version')
          expect(proglang_version.size()).to be 1
          expect(proglang_version.first.value).to eq '1.8'
        end

      end

    end

  end

  describe 'files' do
    let(:xml) {
      ::Nokogiri::XML(
      FactoryGirl.create(:only_meta_data).to_proforma_xml
      ).xpath('/root')[0]
    }

    context 'no files' do

      it 'contains a single empty <p:files>-tag' do
        filesContainer = xml.xpath('p:task/p:files')
        expect(filesContainer.size()).to be 1
        allFiles = xml.xpath('p:task/*/p:file')
        expect(allFiles.size).to be 0
      end

    end

    context 'one Java main file' do
      let(:xml) {
        ::Nokogiri::XML(
          FactoryGirl.create(:exercise_with_single_java_main_file).to_proforma_xml
        ).xpath('/root')[0]
      }

      it 'has single /p:files/p:file tag' do
        files = xml.xpath('p:task/p:files/p:file')
        expect(files.size()).to be 1
      end

      it 'p:file tag has class="template"' do
        filesClass = xml.xpath('p:task/p:files/p:file/@class').first
        expect(filesClass.value).to eq 'template'
      end

      it 'has attribute id on <p:file>-tag' do
        ids = xml.xpath('p:task/p:files/p:file/@id')
        expect(ids.size).to be 1
        expect(ids.first.value.size).to be > 0
      end

      it 'has attribute filename on <p:file>-tag with name and extension' do
        file_names = xml.xpath('p:task/p:files/p:file/@filename')
        expect(file_names.size).to be 1
        expect(file_names.first.value).to eq 'Main.java'
      end

      it 'has attribute class="template" on <p:file>-tag because it is the main file' do
        file_classes = xml.xpath('p:task/p:files/p:file/@class')
        expect(file_classes.size).to be 1
        expect(file_classes.first.value).to eq 'template'
      end

      it 'has attribute comment="main" on <p:file>-tag because it is the main file' do
        file_comments = xml.xpath('p:task/p:files/p:file/@comment')
        expect(file_comments.size).to be 1
        expect(file_comments.first.value).to eq 'main'
      end

      it '<p:file> contains file contents as plain text ' do
        file_contents = xml.xpath('p:task/p:files/p:file/text()')
        expect(file_contents.size).to be 1
        expect(file_contents.first.content).to eq 'public class AsteriksPattern{ public static void main String[] args) { } }'
      end

    end

  end

  describe 'tests' do

    context 'no tests' do
      let(:xml) {
        ::Nokogiri::XML(
        FactoryGirl.create(:only_meta_data).to_proforma_xml
        ).xpath('/root')[0]
      }

      it 'contains a single empty <p:tests>-tag' do
        testsContainer = xml.xpath('p:task/p:tests')
        expect(testsContainer.size()).to be 1
        allTests = xml.xpath('p:task/*/p:test')
        expect(allTests.size).to be 0
      end

    end

    context 'single JUnit test file' do
      let(:xml) {
        doc = ::Nokogiri::XML(
          FactoryGirl.create(:exercise_with_single_junit_test).to_proforma_xml
        )
        doc.collect_namespaces
        return doc.xpath('/root')[0]
      }

      it 'has single <p:tests>/<p:test> tag' do
        print(xml)
        tests = xml.xpath('p:task/p:tests/p:test')
        expect(tests.size()).to be 1
      end

      it '<p:test> contains <p:test-type>unittest</p:test-type>' do
        test_types = xml.xpath('p:task/p:tests/p:test/p:test-type/text()')
        expect(test_types.size()).to be 1
        expect(test_types.first.content).to eq "unittest"
      end

      it '<p:test> contains single <p:test-configuration>/<p:filerefs>/<p:fileref> pointing to correct exercise file' do
        refids = xml.xpath('p:task/p:tests/p:test/p:test-configuration/p:filerefs/p:fileref/@refid')
        expect(refids.size()).to be 1
        refid = refids.first.value
        exercise_file = ExerciseFile.find(refid)
        expect(exercise_file.file_name).to eq "SingleJUnitTestFile"
      end

      it '<p:test-configuration> contains single <c:feedback-message> with feedbackmessage' do
        feedback_messages = xml.xpath('p:task/p:tests/p:test/p:test-configuration/c:feedback-message/text()')
        expect(feedback_messages.size()).to be 1
        expect(feedback_messages.first.content).to eq "Dude... seriously?"
      end

      pending '<p:fileref> points to a <p:file> that actually exists in markup' do
        refids = xml.xpath('p:task/p:tests/p:test/p:test-configuration/p:filerefs/p:fileref/@refid')
        expect(refids.size()).to be 1
        filenames = xml.xpath("p:task/p:files/p:file[@id=#{refids.first.value}]/@filename")
        expect(filenames.size()).to be 1
        expect(filenames.first.value).to eq "SingleJUnitTestFile.java"
      end

      it '<p:test> contains single <p:test-configuration>/<u:unittest framework="JUnit">' do
        frameworks = xml.xpath('p:task/p:tests/p:test/p:test-configuration/u:unittest/@framework')
        expect(frameworks.size()).to be 1
        expect(frameworks.first.value).to eq "JUnit"
      end

    end

    describe 'model solutions' do

      context 'no model solutions' do
        let(:xml) {
          ::Nokogiri::XML(
          FactoryGirl.create(:only_meta_data).to_proforma_xml
          ).xpath('/root')[0]
        }

        it 'contains a single empty <p:model-solutions> tag' do
          model_solutions_container = xml.xpath('p:task/p:model-solutions')
          expect(model_solutions_container.size()).to be 1
          all_model_solutions = xml.xpath('p:task/*/p:model-solution')
          expect(all_model_solutions.size).to be 0
        end

      end

      context 'single model solution file' do
        let(:xml) {
          doc = ::Nokogiri::XML(
            FactoryGirl.create(:exercise_with_single_model_solution).to_proforma_xml
          )
          doc.collect_namespaces
          return doc.xpath('/root')[0]
        }

        it 'has single <p:model-solutions>/<p:model-solution> tag' do
          model_solutions = xml.xpath('p:task/p:model-solutions/p:model-solution')
          expect(model_solutions.size()).to be 1
        end

        it '<p:model-solution> contains single <p:filerefs>/<p:fileref> pointing to correct exercise file' do
          refids = xml.xpath('p:task/p:model-solutions/p:model-solution/p:filerefs/p:fileref/@refid')
          expect(refids.size()).to be 1
          refid = refids.first.value
          exercise_file = ExerciseFile.find(refid)
          expect(exercise_file.file_name).to eq "ModelSolutionFile"
        end

        it '<p:fileref> points to a <p:file> that actually exists in markup' do
          refids = xml.xpath('p:task/p:model-solutions/p:model-solution/p:filerefs/p:fileref/@refid')
          expect(refids.size()).to be 1
          filenames = xml.xpath("p:task/p:files/p:file[@id=#{refids.first.value}]/@filename")
          expect(filenames.size()).to be 1
          expect(filenames.first.value).to eq "ModelSolutionFile.java"
        end

      end

    end

  end
  
  describe 'test creation' do
    context 'and adding description, tasks and tests' do
      let(:exercise){FactoryGirl.create(:only_meta_data)}
      
      it 'does not add anything new' do
        params = {:tests_attributes => nil, :exercise_files_attributes => nil, :descriptions_attributes => nil}
        exercise.add_attributes(params)
        tests = Test.where(exercise_id: exercise.id)
        files = ExerciseFile.where(exercise_id: exercise.id)
        descriptions = Description.where(exercise_id: exercise.id)
        expect(tests.size()).to be 0
        expect(files.size()).to be 0
        expect(descriptions.size()).to be 1
      end
      
      it 'adds stuff' do
        params = {:tests_attributes => {:content =>'this is some test', :feedback_message => 'not_working', :_destroy => false,
            :testing_framework => {:name => 'pytest', :id => '12345678'}},
          :exercise_files_attributes => {:main => 'false', :content => 'some new exercise', :path => 'some/path/', :purpose => 'a new purpose',
            :file_name => 'awesome', :file_extension => '.py', :_destroy => false}, 
          :descriptions_attributes => {:text => 'a new description', :language => 'de', :_destroy => false}}
        exercise.add_attributes(params)
        tests = Test.where(exercise_id: exercise.id)
        files = ExerciseFile.where(exercise_id: exercise.id)
        descriptions = Description.where(exercise_id: exercise.id)
        expect(tests.size()).to be 1
        expect(files.size()).to be 1
        expect(descriptions.size()).to be 2
      end
    end
  end
end
