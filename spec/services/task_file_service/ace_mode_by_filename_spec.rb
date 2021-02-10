# frozen_string_literal: true

require 'rails_helper'

describe TaskFileService::AceModeByFilename do
  describe '.new' do
    subject(:ace_mode_by_filename) { described_class.new(filename: filename) }

    let(:filename) { 'foo.bar' }

    it 'assigns filename' do
      expect(ace_mode_by_filename.instance_variable_get(:@filename)).to be filename
    end
  end

  describe '#execute' do
    subject(:ace_mode_by_filename) { described_class.call(filename: filename) }

    let(:filename) { 'foo.bar' }

    context 'when no filetype exists with extension' do
      it 'defaults to java' do
        expect(ace_mode_by_filename).to eql 'ace/mode/java'
      end
    end

    context 'when filetype with extension exists' do
      before { create(:file_type, file_extension: '.bar', editor_mode: 'ace/mode/bar') }

      it 'returns correct editor_mode' do
        expect(ace_mode_by_filename).to eql 'ace/mode/bar'
      end
    end
  end
end
