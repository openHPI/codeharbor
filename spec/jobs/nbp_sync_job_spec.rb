# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NbpSyncJob do
  let(:task) { create(:task, access_level:) }
  let(:uuid) { task.uuid }

  before do
    allow(Nbp::PushConnector).to receive(:instance).and_return(instance_double(Nbp::PushConnector))
    allow(Nbp::PushConnector.instance).to receive(:push_lom!)
    allow(Nbp::PushConnector.instance).to receive(:delete_task!)
  end

  describe 'perform' do
    subject(:perform_job) { described_class.perform_now(uuid) }

    context 'when the task is public' do
      let(:access_level) { :public }

      it 'pushes the task' do
        perform_job
        expect(Nbp::PushConnector.instance).to have_received(:push_lom!)
      end
    end

    context 'when the task does not exist' do
      let(:uuid) { :not_existing_uuid }

      it 'deletes the task' do
        perform_job
        expect(Nbp::PushConnector.instance).to have_received(:delete_task!)
      end
    end

    context 'when the task is private' do
      let(:access_level) { :private }

      it 'deletes the task' do
        perform_job
        expect(Nbp::PushConnector.instance).to have_received(:delete_task!)
      end
    end
  end
end
