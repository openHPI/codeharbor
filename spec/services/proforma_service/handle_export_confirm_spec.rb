# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::HandleExportConfirm do
  describe '.new' do
    subject(:handle_export_confirm) do
      described_class.new(user:, task:, push_type:, account_link_id:)
    end

    let(:user) { build(:user) }
    let(:task) { build(:task, user:) }
    let(:push_type) { 'export' }
    let(:account_link_id) { create(:account_link, user:).id }

    it 'assigns user' do
      expect(handle_export_confirm.instance_variable_get(:@user)).to be user
    end

    it 'assigns task' do
      expect(handle_export_confirm.instance_variable_get(:@task)).to be task
    end

    it 'assigns push_type' do
      expect(handle_export_confirm.instance_variable_get(:@push_type)).to be push_type
    end

    it 'assigns account_link_id' do
      expect(handle_export_confirm.instance_variable_get(:@account_link_id)).to be account_link_id
    end
  end

  describe '#execute' do
    subject(:handle_export_confirm) do
      described_class.call(user:, task:, push_type:, account_link_id: account_link.id)
    end

    let(:user) { create(:user) }
    let!(:task) { create(:task, user:).reload }
    let(:push_type) { 'export' }
    let(:account_link) { create(:account_link, user:) }

    before do
      allow(ProformaService::ExportTask).to(receive(:call)).and_return('zip_stream')
      allow(TaskService::PushExternal).to(receive(:call))
    end

    it 'returns an array with task and potential errors' do
      expect(handle_export_confirm).to eql [task, nil]
    end

    it 'calls ExportTask-service with correct arguments' do
      handle_export_confirm
      expect(ProformaService::ExportTask).to have_received(:call).with(task:, options: {description_format: 'md'})
    end

    it 'calls PushExternal-service with correct arguments' do
      handle_export_confirm
      expect(TaskService::PushExternal).to have_received(:call).with(zip: 'zip_stream', account_link:)
    end

    context 'when push_type is create_new' do
      let(:push_type) { 'create_new' }

      it 'returns an array with task' do
        expect(handle_export_confirm.first).to be_an Task
      end

      it 'returns a different task then the input' do
        expect(handle_export_confirm.first).not_to eql task
      end

      it 'saves the duplicated task' do
        expect { handle_export_confirm }.to change(Task, :count).by(1)
      end

      it 'does not call ExportTask-service with old task' do
        handle_export_confirm
        expect(ProformaService::ExportTask).to have_received(:call).with(
          task: not_have_attributes(uuid: task.uuid), options: {description_format: 'md'}
        )
      end

      it 'only calls ExportTask-service after uuid has been set' do
        handle_export_confirm
        expect(ProformaService::ExportTask).to have_received(:call).with(
          task: not_have_attributes(uuid: nil), options: {description_format: 'md'}
        )
      end

      it 'calls PushExternal-service with correct arguments' do
        handle_export_confirm
        expect(TaskService::PushExternal).to have_received(:call).with(zip: 'zip_stream', account_link:)
      end
    end
  end
end
