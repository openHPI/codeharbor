# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enmeshed::RelationshipTemplate do
  let(:connector_api_url) { "#{Settings.omniauth.nbp.enmeshed.connector_url}/api/v2" }

  before do
    allow(User).to receive(:omniauth_providers).and_return([:nbp])
  end

  describe '#initialize' do
    it 'raises an error if no valid option is given' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    context 'when a truncated reference is given' do
      subject(:new_template) { described_class.new(truncated_reference:, skip_fetch:) }

      let(:truncated_reference) { 'relationship_template_example_truncated_reference' }
      let(:skip_fetch) { true }

      it 'populates the object with the given attribute' do
        expect(new_template.truncated_reference).to eq truncated_reference
      end

      it 'does not fetch the existing template' do
        expect(new_template.nbp_uid).to be_nil
      end

      context 'when fetching details is enabled' do
        let(:skip_fetch) { false }
        let(:get_relationship_templates_stub) { stub_request(:get, "#{connector_api_url}/RelationshipTemplates?isOwn=true") }

        before do
          stub_request(:get, "#{connector_api_url}/RelationshipTemplates?isOwn=true")
            .to_return(body: file_fixture('enmeshed/valid_relationship_template_created.json'))
        end

        it 'populates the object with the given attribute' do
          expect(new_template.truncated_reference).to eq truncated_reference
        end

        it 'fetches the existing template' do
          expect(new_template.nbp_uid).to eq 'example_uid'
        end

        context 'when no relationship template was found' do
          before do
            get_relationship_templates_stub.to_return(body: file_fixture('enmeshed/no_relationship_templates_yet.json'))
          end

          it 'populates the object with the given attribute' do
            expect(new_template.truncated_reference).to eq truncated_reference
          end

          it 'does not throw an error' do
            expect { new_template.nbp_uid }.not_to raise_error
          end

          it 'returns nil for the unavailable attributes' do
            expect(new_template.nbp_uid).to be_nil
          end
        end

        context 'when the connector is down' do
          before { get_relationship_templates_stub.to_timeout }

          it 'raises an error' do
            expect { new_template }.to raise_error(Faraday::ConnectionFailed)
          end
        end
      end
    end
  end
end
