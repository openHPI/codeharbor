# frozen_string_literal: true

require 'rails_helper'

describe ProformaService::Import do
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
    subject(:import_service) { described_class.call(zip: zip_file, user: import_user) }

    let(:user) { build(:user) }
    let(:import_user) { user }
    let(:zip_file) { Tempfile.new('proforma_test_zip_file', encoding: 'ascii-8bit') }
    let(:exercise) do
      create(:exercise,
             instruction: 'instruction',
             execution_environment: execution_environment,
             exercise_files: files,
             tests: tests,
             uuid: uuid,
             user: user)
    end

    let(:uuid) {}
    let(:execution_environment) { build(:java_8_execution_environment) }
    let(:files) { [] }
    let(:tests) { [] }
    let(:exporter) { ProformaService::ExportTask.call(exercise: exercise.reload).string }

    before do
      zip_file.write(exporter)
      zip_file.rewind
    end

    it { is_expected.to be_an_equal_exercise_as exercise }

    it 'sets the correct user as owner of the exercise' do
      expect(import_service.user).to be user
    end

    it 'sets the uuid' do
      expect(import_service.uuid).not_to be_blank
    end

    context 'when no exercise exists' do
      before { exercise.destroy }

      it { is_expected.to be_valid }

      it 'sets the correct user as owner of the exercise' do
        expect(import_service.user).to be user
      end

      it 'sets the uuid' do
        expect(import_service.uuid).not_to be_blank
      end

      context 'when task has a uuid' do
        let(:uuid) { SecureRandom.uuid }

        it 'sets the uuid' do
          expect(import_service.uuid).to eql uuid
        end
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
      let(:files) { build_list(:codeharbor_solution_file, 2) }

      it { is_expected.to be_an_equal_exercise_as exercise }
    end

    context 'when exercise has a test' do
      let(:tests) { [test] }
      let(:test) { build(:codeharbor_test) }

      it { is_expected.to be_an_equal_exercise_as exercise }
    end

    context 'when exercise has multiple tests' do
      let(:tests) { build_list(:codeharbor_test, 2) }

      it { is_expected.to be_an_equal_exercise_as exercise }
    end

    context 'when zip contains multiple tasks' do
      let(:exporter) { ProformaService::ExportTasks.call(exercises: [exercise, exercise2]).string }

      let(:exercise2) do
        create(:exercise,
               instruction: 'instruction2',
               execution_environment: execution_environment,
               exercise_files: [],
               tests: [],
               user: user)
      end

      it 'imports the exercises from zip containing multiple zips' do
        expect(import_service).to all be_an(Exercise)
      end

      it 'imports the zip exactly how they were exported' do
        expect(import_service).to all be_an_equal_exercise_as(exercise).or be_an_equal_exercise_as(exercise2)
      end

      context 'when a exercise has files and tests' do
        let(:files) { [build(:codeharbor_main_file), build(:codeharbor_regular_file)] }
        let(:tests) { build_list(:codeharbor_test, 2) }

        it 'imports the zip exactly how the were exported' do
          expect(import_service).to all be_an_equal_exercise_as(exercise).or be_an_equal_exercise_as(exercise2)
        end
      end
    end

    context 'when task in zip has a different uuid' do
      let(:uuid) { SecureRandom.uuid }
      let(:new_uuid) { SecureRandom.uuid }

      before do
        exercise.update(uuid: new_uuid)
      end

      it 'creates a new Exercise' do
        expect(import_service.id).not_to be exercise.id
      end
    end

    context 'when task in zip has the same uuid and nothing has changed' do
      let(:uuid) { SecureRandom.uuid }

      it 'updates the old Exercise' do
        expect(import_service.id).to be exercise.id
      end

      it 'creates a predecessor Exercise' do
        expect { import_service }.to change { exercise.reload.predecessor }.from(nil).to(be_an Exercise)
      end

      context 'when another user imports the exercise' do
        let(:import_user) { create(:user) }

        it 'creates a new Exercise' do
          expect(import_service.id).not_to be exercise.id
        end
      end
    end
  end
end
