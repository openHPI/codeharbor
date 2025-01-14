# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enmeshed::RelationshipTemplate do
  let(:connector_api_url) { "#{Settings.omniauth.nbp.enmeshed.connector_url}/api/v2" }
  let(:get_relationship_templates_stub) { stub_request(:get, "#{connector_api_url}/RelationshipTemplates?isOwn=true") }

  before do
    allow(User).to receive(:omniauth_providers).and_return([:nbp])
  end

  describe '#initialize' do
    it 'raises an error if no valid option is given' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    context 'when a truncated reference is given' do
      subject(:new_template) { described_class.new(truncated_reference:) }

      let(:truncated_reference) { 'RelationshipTemplateExampleTruncatedReferenceA==' }

      it 'populates the object with the given attribute' do
        expect(new_template.truncated_reference).to eq truncated_reference
      end

      it 'does not fetch the existing template' do
        expect(new_template.nbp_uid).to be_nil
      end

      context 'when fetching details is enabled' do
        subject(:new_template) { described_class.fetch(truncated_reference) }

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
            expect { new_template }.to raise_error(Faraday::TimeoutError)
          end
        end
      end
    end
  end

  describe '#to_json' do
    context 'when certificate requests are enabled' do
      subject(:template) { described_class.new(truncated_reference: 'example_truncated_reference') }

      before do
        stub_request(:get, "#{connector_api_url}/Account/IdentityInfo")
          .to_return(body: file_fixture('enmeshed/get_enmeshed_address.json'))

        stub_request(:get, "#{connector_api_url}/Attributes?content.@type=IdentityAttribute&content.owner=id_of_an_example_enmeshed_address_AB&content.value.@type=DisplayName")
          .to_return(body: file_fixture('enmeshed/existing_display_name.json'))

        get_relationship_templates_stub.to_return(body: file_fixture('enmeshed/no_relationship_templates_yet.json'))

        allow(Settings).to receive(:dig).with(:omniauth, :nbp, :enmeshed, :allow_certificate_request).and_return(true)
      end

      it 'returns the expected JSON' do
        expect(described_class).to receive(:allow_certificate_request).and_call_original
        expect(template.to_json).to include('CreateAttributeRequestItem')
      end
    end
  end
end
