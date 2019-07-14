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
    subject(:import_service) { described_class.call(zip: zip_file, user: user) }

    let(:user) {}
    let(:zip_file) { Tempfile.new('proforma_test_zip_file') }
    let(:exercise) do
      create(:exercise,
             instruction: 'instruction',
             uuid: SecureRandom.uuid,
             execution_environment: execution_environment,
             exercise_files: files,
             tests: tests)
    end

    let(:execution_environment) { build(:java_8_execution_environment) }
    let(:files) { [] }
    let(:tests) { [] }
    let(:exporter) { ProformaService::ExportTask.call(exercise: exercise).string }

    before do
      zip_file.write(exporter)
      zip_file.rewind
    end

    it { is_expected.to be_an_equal_exercise_as exercise }

    context 'when a user is supplied' do
      let(:user) { build(:user) }

      it 'sets the correct user as owner of the exercise' do
        expect(import_service.user).to be user
      end
    end

    context 'when exercise has a mainfile' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_main_file) }

      it { is_expected.to be_an_equal_exercise_as exercise }

      context 'when the mainfile is very large' do
        let(:file) { build(:codeharbor_main_file, content: 'test' * 10**5) }

        it { is_expected.to be_an_equal_exercise_as exercise }
      end
    end

    context 'when exercise has a regular file' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_regular_file) }

      it { is_expected.to be_an_equal_exercise_as exercise }

      context 'when file has an attachment' do
        let(:file) { build(:codeharbor_regular_file, :with_attachment) }

        it { is_expected.to be_an_equal_exercise_as exercise }
      end
    end

    context 'when exercise has a file with role reference implementation' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_solution_file) }

      it { is_expected.to be_an_equal_exercise_as exercise }
    end

    context 'when exercise has multiple files with role reference implementation' do
      let(:files) { create_list(:codeharbor_solution_file, 2) }

      it { is_expected.to be_an_equal_exercise_as exercise }
    end

    context 'when exercise has a test' do
      let(:tests) { [test] }
      let(:test) { create(:codeharbor_test) }

      it { is_expected.to be_an_equal_exercise_as exercise }
    end

    context 'when exercise has multiple tests' do
      let(:tests) { create_list(:codeharbor_test, 2) }

      it { is_expected.to be_an_equal_exercise_as exercise }
    end

    context 'when zip contains multiple tasks' do
      let(:exporter) { ProformaService::ExportTasks.call(exercises: [exercise, exercise2]).string }

      let(:exercise2) do
        create(:exercise,
               instruction: 'instruction2',
               uuid: SecureRandom.uuid,
               execution_environment: execution_environment,
               exercise_files: [],
               tests: [])
      end

      it 'imports the exercises from zip containing multiple zips' do
        expect(import_service).to all be_an(Exercise)
      end

      it 'imports the zip exactly how the were exported' do
        expect(import_service).to all be_an_equal_exercise_as(exercise).or be_an_equal_exercise_as(exercise2)
      end

      context 'when a exercise has files and tests' do
        let(:files) { create_list(:codeharbor_main_file, 2) }
        let(:tests) { create_list(:codeharbor_test, 2) }

        it 'imports the zip exactly how the were exported' do
          expect(import_service).to all be_an_equal_exercise_as(exercise).or be_an_equal_exercise_as(exercise2)
        end
      end
    end

    xcontext 'when exercise has multiple descriptions' do
      let(:exercise) do
        create(:exercise,
               instruction: 'instruction',
               uuid: SecureRandom.uuid,
               execution_environment: execution_environment,
               exercise_files: files,
               tests: tests,
               descriptions: descriptions)
      end

      let(:descriptions) { create_list :description, 2 }

      it { is_expected.to be_an_equal_exercise_as exercise }
    end
  end
end
