# frozen_string_literal: true

require 'rails_helper'

xdescribe ProformaService::HandleExportConfirm do
  describe '.new' do
    subject(:handle_export_confirm) do
      described_class.new(user: user, exercise: exercise, push_type: push_type, account_link_id: account_link_id)
    end

    let(:user) { build(:user) }
    let(:exercise) { build(:exercise, user: user) }
    let(:push_type) { 'export' }
    let(:account_link_id) { create(:account_link, user: user).id }

    it 'assigns user' do
      expect(handle_export_confirm.instance_variable_get(:@user)).to be user
    end

    it 'assigns exercise' do
      expect(handle_export_confirm.instance_variable_get(:@exercise)).to be exercise
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
      described_class.call(user: user, exercise: exercise, push_type: push_type, account_link_id: account_link.id)
    end

    let(:user) { create(:user) }
    let!(:exercise) { create(:exercise, user: user).reload }
    let(:push_type) { 'export' }
    let(:account_link) { create(:account_link, user: user) }

    before do
      allow(ProformaService::ExportTask).to(receive(:call)).and_return('zip_stream')
      allow(TaskService::PushExternal).to(receive(:call))
    end

    it 'returns an array with exercise and potential errors' do
      expect(handle_export_confirm).to eql [exercise, nil]
    end

    it 'calls ExportTask-service with correct arguments' do
      handle_export_confirm
      expect(ProformaService::ExportTask).to have_received(:call).with(exercise: exercise, options: {description_format: 'md'})
    end

    it 'calls PushExternal-service with correct arguments' do
      handle_export_confirm
      expect(TaskService::PushExternal).to have_received(:call).with(zip: 'zip_stream', account_link: account_link)
    end

    context 'when push_type is create_new' do
      RSpec::Matchers.define_negated_matcher :not_have_attributes, :have_attributes

      let(:push_type) { 'create_new' }

      before { create(:relation, name: 'Derivate') }

      it 'returns an array with exercise' do
        expect(handle_export_confirm.first).to be_an Exercise
      end

      it 'returns a different exercise then the input' do
        expect(handle_export_confirm.first).not_to eql exercise
      end

      it 'saves the duplicated exercise' do
        expect { handle_export_confirm }.to change(Exercise, :count).by(1)
      end

      it 'does not call ExportTask-service with old exercise' do
        handle_export_confirm
        expect(ProformaService::ExportTask).to have_received(:call).with(
          exercise: not_have_attributes(uuid: exercise.uuid), options: {description_format: 'md'}
        )
      end

      it 'only calls ExportTask-service after uuid has been set' do
        handle_export_confirm
        expect(ProformaService::ExportTask).to have_received(:call).with(
          exercise: not_have_attributes(uuid: nil), options: {description_format: 'md'}
        )
      end

      # it 'calls PushExternal-service with correct arguments' do
      #   handle_export_confirm
      #   expect(ExerciseService::PushExternal).to have_received(:call).with(zip: 'zip_stream', account_link: account_link)
      # end
    end
  end
end
