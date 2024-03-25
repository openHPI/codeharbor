# frozen_string_literal: true

require 'rails_helper'

# Since the OmniAuth::Strategies::MockSaml class is only loaded if enabled, we need some workaround to test it.
# Once enabled in the before block, we require the file to load the class.
# Then, we test the class as usual.
RSpec.describe 'OmniAuth::Strategies::MockSaml' do
  let(:described_class) { OmniAuth::Strategies::MockSaml }

  let(:strategy) { described_class.new(nil) }
  let(:idp_metadata_parser) { instance_double(OneLogin::RubySaml::IdpMetadataParser) }
  let(:idp_metadata) { {issuer: 'https://example.com', idp_sso_target_url: 'https://example.com/login'} }

  before do
    allow(Settings.omniauth.mocksaml).to receive(:enable).and_return(true)
    allow(OneLogin::RubySaml::IdpMetadataParser).to receive(:new).and_return(idp_metadata_parser)
    allow(idp_metadata_parser).to receive(:parse_remote_to_hash).and_return(idp_metadata)
    require 'omni_auth/strategies/mock_saml'
  end

  it 'configures the strategy with the idp metadata' do
    expect(strategy.options.issuer).to eq('https://example.com')
    expect(strategy.options.idp_sso_target_url).to eq('https://example.com/login')
  end

  context 'when uid is present' do
    before do
      strategy.instance_variable_set(:@attributes, {
        'id' => '123',
      })
    end

    it 'returns the uid from the attributes' do
      expect(strategy.uid).to eq('123')
    end
  end

  context 'when uid is not present' do
    before do
      strategy.instance_variable_set(:@attributes, {})
      strategy.instance_variable_set(:@name_id, 'abc')
    end

    it 'returns the name_id as the uid' do
      expect(strategy.uid).to eq('abc')
    end
  end

  context 'when user info is present' do
    before do
      strategy.instance_variable_set(:@attributes, {
        'email' => 'test@example.com',
        'firstName' => 'John',
        'lastName' => 'Doe',
      })
    end

    it 'returns the correct user info' do
      expect(strategy.info).to eq({
        email: 'test@example.com',
        name: 'John Doe',
        first_name: 'John',
        last_name: 'Doe',
        display_name: 'John',
      })
    end
  end
end
