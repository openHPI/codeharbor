# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OmniAuth::Strategies::AbstractSaml do
  let(:strategy) { described_class.new(nil) }
  let(:env) { {} }
  let(:session) { {} }

  describe '#idp_slo_session_destroy' do
    before do
      env['warden'] = instance_double(Warden::Proxy).as_null_object
      env['rack.session'] = instance_double(ActionDispatch::Request::Session, options: {}).as_null_object
      session[:user_id] = 1
    end

    it 'clears the session' do
      strategy.options[:idp_slo_session_destroy].call(env, session)
      expect(session).to be_empty
    end

    it 'sets secure session option to true' do
      strategy.options[:idp_slo_session_destroy].call(env, session)
      expect(env['rack.session'].options[:secure]).to be true
    end

    it 'sets same_site session option to none' do
      strategy.options[:idp_slo_session_destroy].call(env, session)
      expect(env['rack.session'].options[:same_site]).to eq(:none)
    end

    it 'calls logout on warden' do
      expect(env['warden']).to receive(:logout)
      strategy.options[:idp_slo_session_destroy].call(env, session)
    end

    context 'when in development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        strategy.options[:idp_slo_session_destroy].call(env, session)
      end

      it 'sets HTTP_X_FORWARDED_PROTO to https' do
        expect(env['HTTP_X_FORWARDED_PROTO']).to eq('https')
      end
    end
  end

  describe '#info' do
    before do
      strategy.instance_variable_set(:@attributes, {
        'urn:oid:0.9.2342.19200300.100.1.3' => 'email@example.com',
        'urn:oid:2.5.4.3' => 'name',
        'urn:oid:2.5.4.42' => 'first_name',
        'urn:oid:2.5.4.4' => 'last_name',
        'urn:oid:2.16.840.1.113730.3.1.241' => 'display_name',
      })
    end

    it 'returns the correct info hash' do
      expect(strategy.info).to eq({
        email: 'email@example.com',
        name: 'name',
        first_name: 'first_name',
        last_name: 'last_name',
        display_name: 'display_name',
      })
    end
  end

  describe '#uid' do
    context 'when name_id is present' do
      before do
        strategy.instance_variable_set(:@name_id, 'name_id')
      end

      it 'returns the name_id' do
        expect(strategy.uid).to eq('name_id')
      end
    end

    context 'when name_id is not present' do
      before do
        strategy.instance_variable_set(:@attributes, {
          'urn:oid:0.9.2342.19200300.100.1.1' => 'uid',
        })
      end

      it 'returns the uid from attributes' do
        expect(strategy.uid).to eq('uid')
      end
    end
  end

  describe '#with_settings' do
    let(:current_user) { create(:user) }
    let(:mock_request) { instance_double(ActionDispatch::Request) }
    let(:test_proc) { ->(first_arg, *_other_args) { first_arg } }
    let(:on_request_path?) { true }

    before do
      allow(strategy).to receive_messages(full_host: 'https://example.com', script_name: '', request_path: '/users/auth/provider', current_user:, on_request_path?: on_request_path?, request: mock_request)
      allow(mock_request).to receive_messages(params: {}, query_string: '')
      allow(OmniAuth::NonceStore).to receive(:add).with(current_user&.id).and_return('nonce')
      strategy.with_settings(&test_proc)
    end

    it 'sets name_identifier_format option to persistent' do
      expect(strategy.options[:name_identifier_format]).to eq('urn:oasis:names:tc:SAML:2.0:nameid-format:persistent')
    end

    it 'sets sp_entity_id option to sso_path' do
      expect(strategy.options[:sp_entity_id]).to eq(strategy.sso_path)
    end

    it 'sets single_logout_service_url option to slo_path' do
      expect(strategy.options[:single_logout_service_url]).to eq(strategy.slo_path)
    end

    it 'sets slo_default_relay_state option to full_host' do
      expect(strategy.options[:slo_default_relay_state]).to eq(strategy.full_host)
    end

    it 'yields the block and returns a Settings object' do
      expect(strategy.with_settings(&test_proc)).to be_an_instance_of(OneLogin::RubySaml::Settings)
    end

    context 'when on request path and current user exists' do
      it 'sets relay_state param to nonce' do
        expect(strategy.request.params['relay_state']).to eq('nonce')
      end
    end

    context 'when not on request path' do
      let(:on_request_path?) { false }

      it 'does not set relay_state param' do
        expect(strategy.request.params['relay_state']).to be_nil
      end
    end

    context 'when current user does not exist' do
      let(:current_user) { nil }

      it 'does not set relay_state param' do
        expect(strategy.request.params['relay_state']).to be_nil
      end
    end
  end

  describe '#sso_path' do
    before do
      allow(strategy).to receive_messages(full_host: 'https://example.com', script_name: '/auth', request_path: '/saml')
    end

    it 'returns the correct sso path' do
      expect(strategy.sso_path).to eq('https://example.com/auth/saml')
    end
  end

  describe '#slo_path' do
    before do
      allow(strategy).to receive_messages(full_host: 'https://example.com', script_name: '/auth', request_path: '/saml')
    end

    it 'returns the correct slo path' do
      expect(strategy.slo_path).to eq('https://example.com/auth/saml/slo')
    end
  end

  describe '#current_user' do
    let(:warden) { instance_double(Warden::Proxy) }
    let(:user) { instance_double(User) }

    before do
      allow(strategy).to receive(:env).and_return({'warden' => warden})
      allow(warden).to receive(:user).and_return(user)
    end

    it 'returns the current user' do
      expect(strategy.current_user).to eq(user)
    end
  end

  describe '.desired_bindings' do
    it 'returns the correct desired bindings' do
      expect(described_class.desired_bindings).to eq({
        sso_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
        slo_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      })
    end
  end
end
