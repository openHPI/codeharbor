# frozen_string_literal: true

require 'rails_helper'

describe ProformaService::Import do
  describe '.new' do
    subject(:import_service) { described_class.new(zip:, user:) }

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
    let(:task) do
      create(:task,
             :with_content,
             programming_language:,
             meta_data:,
             files:,
             tests:,
             model_solutions:,
             uuid:,
             user:)
    end

    let(:uuid) {}
    let(:programming_language) { build(:programming_language, :ruby) }
    let(:meta_data) {}
    let(:files) { [] }
    let(:model_solutions) { [] }
    let(:tests) { [] }
    let(:exporter) { ProformaService::ExportTask.call(task: task.reload).string }

    before do
      zip_file.write(exporter)
      zip_file.rewind
    end

    it { is_expected.to be_an_equal_task_as task }

    it 'sets the correct user as owner of the task' do
      expect(import_service.user).to be user
    end

    it 'sets the uuid' do
      expect(import_service.uuid).not_to be_blank
    end

    context 'when no task exists' do
      before { task.destroy }

      it { is_expected.to be_valid }

      it 'sets the correct user as owner of the task' do
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

    context 'when task has meta_data' do
      let(:meta_data) { {CodeOcean: {meta: 'data', nested: {other: 'data'}}} }

      it 'sets the meta_data' do
        expect(import_service.meta_data).to eql meta_data
      end
    end

    context 'when task has a file' do
      let(:files) { [file] }
      let(:file) { build(:task_file, :exportable) }

      it { is_expected.to be_an_equal_task_as task }

      context 'when the mainfile is very large' do
        let(:file) { build(:task_file, :exportable, content: 'test' * (10**5)) }

        it { is_expected.to be_an_equal_task_as task }
      end

      context 'when file has an attachment' do
        let(:file) { build(:task_file, :exportable, :with_attachment, mime_type: 'image/bmp') }

        it { is_expected.to be_an_equal_task_as task }
      end
    end

    context 'when task has a model_solution' do
      let(:model_solutions) { [model_solution] }
      let(:model_solution) { build(:model_solution, files: [build(:task_file, :exportable)]) }

      it { is_expected.to be_an_equal_task_as task }
    end

    context 'when task has multiple files with role reference implementation' do
      let(:model_solutions) { [model_solution, model_solution2] }
      let(:model_solution) { build(:model_solution, :with_content, files: [build(:task_file, :exportable)]) }
      let(:model_solution2) { build(:model_solution, :with_content, files: [build(:task_file, :exportable)]) }

      it { is_expected.to be_an_equal_task_as task }
    end

    context 'when task has a test' do
      let(:tests) { [test] }
      let(:test) { build(:test, :with_content, meta_data: test_meta_data) }
      let(:test_meta_data) {}

      it { is_expected.to be_an_equal_task_as task }

      context 'when task has meta_data' do
        let(:test_meta_data) { {CodeOcean: {meta: 'data', nested: {other: 'data'}}} }

        it 'sets the meta_data' do
          expect(import_service.tests.first.meta_data).to eql test_meta_data
        end
      end
    end

    context 'when task has multiple tests' do
      let(:tests) { build_list(:test, 2, :with_content) }

      it { is_expected.to be_an_equal_task_as task }
    end

    context 'when zip contains multiple tasks' do
      let(:exporter) { ProformaService::ExportTasks.call(tasks: [task, task2]).string }

      let(:task2) do
        create(:task,
               programming_language:,
               files: [],
               tests: [],
               user:)
      end

      it 'imports the tasks from zip containing multiple zips' do
        expect(import_service).to all be_an(Task)
      end

      it 'imports the zip exactly how they were exported' do
        expect(import_service).to all be_an_equal_task_as(task).or be_an_equal_task_as(task2)
      end

      context 'when a task has files and tests' do
        let(:files) { [build(:task_file, :exportable), build(:task_file, :exportable)] }
        let(:tests) { build_list(:test, 2, test_type: 'test_type') }

        it 'imports the zip exactly how the were exported' do
          expect(import_service).to all be_an_equal_task_as(task).or be_an_equal_task_as(task2)
        end
      end
    end

    context 'when task in zip has a different uuid' do
      let(:uuid) { SecureRandom.uuid }
      let(:new_uuid) { SecureRandom.uuid }

      before do
        task.update(uuid: new_uuid)
      end

      it 'creates a new task' do
        expect(import_service.id).not_to be task.id
      end
    end

    context 'when task in zip has the same uuid and nothing has changed' do
      let(:uuid) { SecureRandom.uuid }

      it 'updates the old task' do
        expect(import_service.id).to be task.id
      end

      context 'when another user imports the task' do
        let(:import_user) { create(:user) }

        it 'creates a new task' do
          expect(import_service.id).not_to be task.id
        end
      end
    end
  end
end
