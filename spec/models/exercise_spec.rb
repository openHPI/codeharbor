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

end
