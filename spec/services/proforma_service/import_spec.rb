# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::Import do
  describe '.new' do
    subject(:import_service) { described_class.new(zip: zip, user: user) }

    let(:zip) { Tempfile.new('proforma_test_zip_file') }
    let(:user) { build(:user) }

    it 'assigns zip' do
      expect(import_service.instance_variable_get(:@zip)).to be zip
    end

    it 'assigns user' do
      expect(import_service.instance_variable_get(:@user)).to be user
    end
  end

  describe '#execute' do
    subject(:perform) { import_service.perform }

    let(:exercise) { build(:simple_exercise) }
    let(:zip_file) { Tempfile.new('proforma_test_zip_file') }
    let(:import_service) { described_class.new(zip_file) }

    before do
      zip_file.write(ProformaService::ExportTask.call(exercise: exercise).string)
      zip_file.rewind
    end

    fit 'a' do
      file_type = create(:file_type)
      FactoryBot.rewind_sequences
      exercise1 = build(:simple_exercise,
                        descriptions: [Description.new(text: 'asd')],
                        tests: [build(:test, feedback_message: 'asd')],
                        exercise_files: [build(:exercise_file, file_type: file_type)])
      FactoryBot.rewind_sequences
      exercise2 = build(:exercise,
                        descriptions: [Description.new(text: 'asd')],
                        tests: [build(:test, feedback_message: 'asd')],
                        exercise_files: [build(:exercise_file, file_type: file_type)])
      expect(exercise1).to be_an_equal_exercise_as exercise2
    end
  end
end
