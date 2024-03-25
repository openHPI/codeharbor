# frozen_string_literal: true

require 'rails_helper'

# Since the OmniAuth::Strategies::Bird class is only loaded if enabled, we need some workaround to test it.
# Once enabled in the before block, we require the file to load the class.
# Then, we test the class as usual.
RSpec.describe 'OmniAuth::Strategies::Bird' do
  let(:described_class) { OmniAuth::Strategies::Bird }

  let(:strategy) { described_class.new(nil) }
  let(:idp_metadata_parser) { instance_double(OneLogin::RubySaml::IdpMetadataParser) }
  let(:idp_metadata) { {issuer: 'https://example.com', idp_sso_target_url: 'https://example.com/login'} }

  before do
    allow(Settings.omniauth.bird).to receive_messages(enable: true, certificate: 'certificate path', private_key: 'private key path')
    allow(File).to receive(:read).and_return('certificate content', 'private key content')
    allow(OneLogin::RubySaml::IdpMetadataParser).to receive(:new).and_return(idp_metadata_parser)
    allow(idp_metadata_parser).to receive(:parse_remote_to_hash).and_return(idp_metadata)
    require 'omni_auth/strategies/bird'
  end

  it 'configures the strategy with the idp metadata' do
    expect(strategy.options.issuer).to eq('https://example.com')
    expect(strategy.options.idp_sso_target_url).to eq('https://example.com/login')
  end
end
