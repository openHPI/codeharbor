# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nbp::PushConnector do
  let(:api_host) { Settings.nbp.push_connector.api_host }
  let(:source_slug) { Settings.nbp.push_connector.source.slug }
  let(:token_expiration) { 600 }

  let(:task) { create(:task) }
  let(:task_xml_builder) { Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| LomService::ExportLom.call(task:, xml:) } }
  let(:task_xml) { task_xml_builder.to_xml }

  let(:connector) { Class.new(described_class).instance } # https://stackoverflow.com/a/23901644

  before do
    stub_request(:post, Settings.nbp.push_connector.token_path).to_return_json(body: {access_token: 'sometoken', expires_in: token_expiration})
    stub_request(:post, "#{api_host}/datenraum/api/core/sources")
    stub_request(:put, "#{api_host}/push-connector/api/lom-v2/#{source_slug}")
    stub_request(:delete, %r{#{api_host}/push-connector/api/course/#{source_slug}/})
    stub_request(:get, "#{api_host}/datenraum/api/core/sources/slug/#{source_slug}").to_return(status: 404)

    stub_request(:get, %r{#{api_host}/datenraum/api/core/nodes})
      .to_return(body: file_fixture('nbp/empty_nodes.json'))

    stub_request(:get, %r{#{api_host}/datenraum/api/core/nodes})
      .with(query: hash_including('offset' => '0'))
      .to_return(body: file_fixture('nbp/nodes.json'))
  end

  describe 'initialize' do
    context 'when no source exists' do
      it 'creates a source' do
        connector
        expect(WebMock).to have_requested(:post, "#{api_host}/datenraum/api/core/sources")
      end

      context 'when the push connector is disabled' do
        before do
          # Disable push connector temporarily
          Settings.nbp.push_connector.enable = false
          described_class.remove_instance_variable(:@enabled) if described_class.instance_variable_defined?(:@enabled)
        end

        after do
          # Allow push connector to be re-enabled
          Settings.nbp.push_connector.enable = true
          described_class.remove_instance_variable(:@enabled) if described_class.instance_variable_defined?(:@enabled)
        end

        it 'raises an error' do
          expect { connector }.to raise_error(Nbp::PushConnector::SettingsError)
        end
      end
    end

    context 'when a source exists' do
      before { stub_request(:get, "#{api_host}/datenraum/api/core/sources/slug/#{source_slug}").to_return(status: 200) }

      it 'does not create a source' do
        connector
        expect(WebMock).not_to have_requested(:post, "#{api_host}/datenraum/api/core/sources")
      end
    end

    context 'when the source could not be determined' do
      before { stub_request(:get, "#{api_host}/datenraum/api/core/sources/slug/#{source_slug}").to_return(status: 500) }

      it 'does not create a source' do
        begin
          connector
        rescue Nbp::PushConnector::Error
          # no op for the spec
        end

        expect(WebMock).not_to have_requested(:post, "#{api_host}/datenraum/api/core/sources")
      end

      it 'raises an error' do
        expect { connector }.to raise_error(Nbp::PushConnector::Error)
      end
    end
  end

  describe 'push_lom!' do
    subject(:push_lom!) { connector.push_lom!(task_xml) }

    context 'without any errors' do
      it 'pushes the metadata' do
        push_lom!
        expect(WebMock).to have_requested(:put, "#{api_host}/push-connector/api/lom-v2/#{source_slug}")
      end
    end

    context 'when the token is still valid' do
      before do
        connector
        WebMock.reset_executed_requests!
      end

      it 'does not renew the token' do
        push_lom!
        expect(WebMock).not_to have_requested(:post, Settings.nbp.push_connector.token_path)
      end
    end

    context 'when the token expired' do
      let(:token_expiration) { 0 }

      before do
        connector
        WebMock.reset_executed_requests!
      end

      it 'renews the token' do
        push_lom!
        expect(WebMock).to have_requested(:post, Settings.nbp.push_connector.token_path)
      end
    end

    context 'when the token cannot be renewed' do
      let(:token_expiration) { 0 }

      before do
        connector
        stub_request(:post, Settings.nbp.push_connector.token_path).to_return_json(body: {}, status: 500)
        WebMock.reset_executed_requests!
      end

      it 'raises an error' do
        expect { push_lom! }.to raise_error(Nbp::PushConnector::Error)
      end

      it 'does not push the metadata' do
        begin
          push_lom!
        rescue Nbp::PushConnector::Error
          # no op for the spec
        end

        expect(WebMock).not_to have_requested(:put, "#{api_host}/push-connector/api/lom-v2/#{source_slug}")
      end
    end
  end

  describe 'delete_task!' do
    subject(:delete_task!) { connector.delete_task!(task.uuid) }

    context 'without any errors' do
      it 'pushes the metadata' do
        delete_task!
        expect(WebMock).to have_requested(:delete, "#{api_host}/push-connector/api/course/#{source_slug}/#{task.uuid}")
      end
    end
  end

  describe 'process_uploaded_task_uuids' do
    it 'iterates the correct UUIDs' do
      uuids = []
      connector.process_uploaded_task_uuids {|uuid| uuids << uuid }
      expect(uuids).to eq(%w[external-id-1 external-id-2 external-id-3])
    end
  end
end
