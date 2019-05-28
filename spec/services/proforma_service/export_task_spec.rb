# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ExportTask do
  describe '.new' do
    subject(:export_service) { described_class.new(exercise: exercise) }

    let(:exercise) { build(:exercise) }

    it 'assigns exercise' do
      expect(export_service.instance_variable_get(:@exercise)).to be exercise
    end
  end

  describe '#execute' do
    subject(:execute) { export_service.execute }

    let(:export_service) { described_class.new(exercise: exercise) }
    let(:exercise) { build(:exercise, :exportable, instruction: 'instruction', uuid: SecureRandom.uuid) }

    let(:zip_files) do
      {}.tap do |hash|
        Zip::InputStream.open(execute) do |io|
          while (entry = io.get_next_entry)
            hash[entry.name] = entry.get_input_stream.read
          end
        end
      end
    end
    let(:doc) { Nokogiri::XML(zip_files['task.xml'], &:noblanks) }
    let(:xml) { doc.remove_namespaces! }

    it_behaves_like 'zipped task node xml'

    it 'adds title node with correct content to task node' do
      expect(xml.xpath('/task/title').text).to eql exercise.title
    end

    it 'adds description node with correct content to task node' do
      expect(xml.xpath('/task/description').text).to eql exercise.descriptions.first.text
    end

    it 'adds proglang node with correct content to task node' do
      expect(xml.xpath('/task/proglang').text).to eql exercise.execution_environment.language
    end

    it 'adds version attribute to proglang node' do
      expect(xml.xpath('/task/proglang').attribute('version').value).to eql exercise.execution_environment.version
    end

    it 'adds internal-description node with correct content to task node' do
      expect(xml.xpath('/task/internal-description').text).to eql exercise.instruction
    end

    it 'adds uuid attribute to task node' do
      expect(xml.xpath('/task').attribute('uuid').value).to eql exercise.uuid
    end

  end
end
