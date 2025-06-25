# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::Validation do
  describe '.new' do
    subject(:validation) do
      described_class.new(task:)
    end

    let(:task) { build(:task) }

    it 'assigns task' do
      expect(validation.instance_variable_get(:@task)).to be task
    end
  end

  describe '.call' do
    subject(:validation) { described_class.call(task:) }

    let(:task) { create(:task) }

    before do
      stub_const('ProformaXML::SCHEMA_VERSIONS', ['2.0', '2.1'])
    end

    context 'when the task is valid for all schema versions' do
      before do
        allow(ProformaService::ExportTask).to receive(:call).and_return(true)
      end

      it 'returns a hash with all versions as valid' do
        expect(validation[nil]).to be true
        expect(validation['2.0']).to be true
        expect(validation['2.1']).to be true
      end
    end

    context 'when the task is invalid for a schema version' do
      before do
        allow(ProformaService::ExportTask).to receive(:call).and_raise(ProformaXML::PostGenerateValidationError, '["not valid"]')
      end

      it 'returns a hash with all versions as invalid' do
        expect(validation[nil]).to be false
        expect(validation['2.0']).to be false
        expect(validation['2.1']).to be false
      end
    end

    context 'when some versions are valid and others are invalid' do
      before do
        allow(ProformaService::ExportTask).to receive(:call)
          .with(task: task, options: {version: '2.0'})
          .and_return(true)

        allow(ProformaService::ExportTask).to receive(:call)
          .with(task: task, options: {version: '2.1'})
          .and_raise(ProformaXML::PostGenerateValidationError, '["not valid"]')
      end

      it 'returns a hash with correct validity for each version' do
        expect(validation['2.0']).to be true
        expect(validation['2.1']).to be false
        expect(validation[nil]).to be false
      end
    end
  end
end
