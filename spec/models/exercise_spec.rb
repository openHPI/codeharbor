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
          print(xml)
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
        print(xml)
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
        file_names = xml.xpath('p:task/p:files/p:file/@class')
        expect(file_names.size).to be 1
        expect(file_names.first.value).to eq 'template'
      end

      it '<p:file> contains file contents as plain text ' do
        file_contents = xml.xpath('p:task/p:files/p:file/text()')
        expect(file_contents.size).to be 1
        expect(file_contents.first.content).to eq 'public class AsteriksPattern{ public static void main String[] args) { } }'
      end

    end

  end

end
