# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NbpSyncAllJob do
  include ActiveJob::TestHelper

  let(:api_host) { Settings.nbp.push_connector.api_host }
  let(:source_slug) { Settings.nbp.push_connector.source.slug }

  let!(:local_uuids) { create_list(:task, 3, access_level: :public).pluck(:uuid) }
  let!(:uploaded_uuids) { [Random.uuid, local_uuids.first, local_uuids.second] }
  let!(:all_uuids) { local_uuids | uploaded_uuids }

  before do
    stub_request(:post, Settings.nbp.push_connector.token_path).to_return_json(body: {token: 'sometoken', expires_in: 600})
    stub_request(:get, "#{api_host}/datenraum/api/core/sources/slug/#{source_slug}").to_return(status: 200)

    allow(Nbp::PushConnector.instance).to receive(:get_uploaded_task_uuids).with(0).and_return(uploaded_uuids)
    allow(Nbp::PushConnector.instance).to receive(:get_uploaded_task_uuids).with(3).and_return([])
  end

  describe 'perform' do
    subject(:perform_job) { described_class.perform_now }

    it 'schedules the correct sync jobs' do
      expect { perform_job }.to have_enqueued_job(NbpSyncJob).with(all_uuids.first)
        .and have_enqueued_job(NbpSyncJob).with(all_uuids.second)
        .and have_enqueued_job(NbpSyncJob).with(all_uuids.third)
        .and have_enqueued_job(NbpSyncJob).with(all_uuids.fourth)
    end
  end

  describe 'rake' do
    subject(:push_all) { Rake::Task['nbp:push_all'].invoke }

    before { Rails.application.load_tasks if Rake::Task.tasks.empty? }

    it 'schedules the desired job' do
      expect { push_all }.to have_enqueued_job(described_class)
    end
  end
end
