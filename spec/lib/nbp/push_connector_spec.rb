# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nbp::PushConnector do
  let(:api_host) { Settings.nbp.push_connector.api_host }
  let(:source_slug) { Settings.nbp.push_connector.source.slug }

  let(:task) { create(:task) }
  let(:task_xml) { (Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| LomService::ExportLom.call(task:, xml:) }).to_xml }

  let(:connector) { Class.new(described_class).instance } # https://stackoverflow.com/a/23901644

  before do
    stub_request(:post, Settings.nbp.push_connector.token_path).to_return_json(body: {token: 'sometoken', expires_in: 600})
    stub_request(:post, "#{api_host}/datenraum/api/core/sources")
    stub_request(:put, "#{api_host}/push-connector/api/lom-v2/#{source_slug}")
    stub_request(:get, "#{api_host}/datenraum/api/core/sources/slug/#{source_slug}").to_return(status: 404)
  end

  describe 'push_lom!' do
    subject(:push_lom!) { connector.push_lom!(task_xml) }

    context 'when no source exists' do
      it 'creates a source' do
        push_lom!
        expect(WebMock).to have_requested(:post, "#{api_host}/datenraum/api/core/sources")
      end
    end

    context 'when a source exists' do
      before { stub_request(:get, "#{api_host}/datenraum/api/core/sources/slug/#{source_slug}").to_return(status: 200) }

      it 'does not create a source' do
        push_lom!
        expect(WebMock).not_to have_requested(:post, "#{api_host}/datenraum/api/core/sources")
      end
    end

    context 'without any errors' do
      it 'pushes the metadata' do
        push_lom!
        expect(WebMock).to have_requested(:put, "#{api_host}/push-connector/api/lom-v2/#{source_slug}")
      end
    end
  end
end
