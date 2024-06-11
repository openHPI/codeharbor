# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController do
  render_views

  describe '#destroy' do
    context 'with SAML login' do
      let(:omniauth_provider) { User.omniauth_providers.first.to_s }
      let(:saml_uid) { 'saml_uid' }
      let(:saml_session_index) { 'saml_session_index' }

      before do
        OmniAuth.config.test_mode = true
        request.env['devise.mapping'] = Devise.mappings[:user]

        # Add a new provider to the omniauth config and reload routes
        Devise.omniauth :sso_callback, strategy_class: OmniAuth::Strategies::AbstractSaml
        Rails.application.reload_routes!

        session[:saml_uid] = saml_uid
        session[:saml_session_index] = saml_session_index
        session[:omniauth_provider] = omniauth_provider
      end

      after do
        # Remove the provider from the omniauth config and reload routes
        Devise.class_variable_set(:@@omniauth_configs, {}) # rubocop:disable Style/ClassVars
        Rails.application.reload_routes!
      end

      context 'when SLO is supported' do
        before do
          options = OmniAuth::Strategy::Options.new(idp_slo_service_url: 'https://idp.example.com/slo')
          allow(OmniAuth::Strategies::AbstractSaml).to receive(:default_options).and_return(options)
        end

        it 'redirects to the IdP SLO path' do
          delete :destroy
          expect(response).to redirect_to(controller.send(:spslo_path_for, omniauth_provider))
        end

        it 'preserves the SAML information in the session' do
          delete :destroy
          expect(session[:saml_uid]).to eq(saml_uid)
          expect(session[:saml_session_index]).to eq(saml_session_index)
          expect(session[:omniauth_provider]).to eq(omniauth_provider)
        end
      end

      context 'when SLO is not supported' do
        it 'redirects to the root path' do
          delete :destroy
          expect(response).to redirect_to(root_path)
        end

        it 'clears the session' do
          delete :destroy
          expect(session[:saml_uid]).to be_nil
          expect(session[:saml_session_index]).to be_nil
          expect(session[:omniauth_provider]).to be_nil
        end
      end
    end
  end
end
