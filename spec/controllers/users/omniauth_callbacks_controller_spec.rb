# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController do
  render_views

  let(:omniauth_provider) { 'provider' }

  before do
    OmniAuth.config.test_mode = true
    request.env['devise.mapping'] = Devise.mappings[:user]

    # Add a new provider to the omniauth config and reload routes
    Devise.omniauth :sso_callback
    Rails.application.reload_routes!
  end

  after do
    # Remove the provider from the omniauth config and reload routes
    Devise.class_variable_set(:@@omniauth_configs, {}) # rubocop:disable Style/ClassVars
    Rails.application.reload_routes!
  end

  describe '#sso_callback' do
    let(:info) { attributes_for(:user) }
    let(:auth) { OmniAuth::AuthHash.new(provider: omniauth_provider, uid: 'uid', info:) }

    before do
      request.env['omniauth.auth'] = auth
    end

    context 'when user is new' do
      it 'creates a new user' do
        expect { post :sso_callback }.to change(User, :count).by(1)
      end

      it 'creates a new identity' do
        expect { post :sso_callback }.to change(UserIdentity, :count).by(1)
      end

      it 'redirects to the root page' do
        post :sso_callback
        expect(response).to redirect_to root_path
      end

      context 'when no user can be created' do
        before do
          # Create a user with the same information passed through the omniauth hash; this will fail validation.
          create(:user, **info)
        end

        it 'does not create a new user' do
          expect { post :sso_callback }.not_to change(User, :count)
        end

        it 'does not create a new identity' do
          expect { post :sso_callback }.not_to change(UserIdentity, :count)
        end

        it 'redirects to the new_user_registration_url' do
          post :sso_callback
          expect(response).to redirect_to new_user_registration_url
        end
      end
    end

    context 'when user exists' do
      let(:user) { create(:user) }

      context 'when signing in' do
        before do
          create(:user_identity, user:, omniauth_provider: auth.provider, provider_uid: auth.uid)
        end

        it 'does not create a new user' do
          expect { post :sso_callback }.not_to change(User, :count)
        end

        it 'does not create a new identity' do
          expect { post :sso_callback }.not_to change(UserIdentity, :count)
        end

        it 'redirects to root path' do
          post :sso_callback
          expect(response).to redirect_to root_path
        end
      end

      context 'when adding a new identity' do
        before do
          allow(OmniAuth::NonceStore).to receive(:pop).and_return(user.id)
        end

        it 'does not create a new user' do
          expect { post :sso_callback }.not_to change(User, :count)
        end

        it 'creates a new identity' do
          expect { post :sso_callback }.to change(UserIdentity, :count).by(1)
        end

        it 'redirects to the edit_user_registration_path' do
          post :sso_callback
          expect(response).to redirect_to edit_user_registration_path
        end
      end
    end
  end

  describe '#deauthorize' do
    shared_examples 'no removal of affected provider in the session' do
      let(:provider) { omniauth_provider }

      before do
        session[:omniauth_provider] = provider
        session[:saml_uid] = 'saml_uid'
        session[:saml_session_index] = 'saml_session_index'
        delete :deauthorize, params: {provider: omniauth_provider}
      end

      it 'does not remove the provider from the session' do
        expect(session[:omniauth_provider]).to eq provider
      end

      it 'does not remove the saml_uid from the session' do
        expect(session[:saml_uid]).to eq 'saml_uid'
      end

      it 'does not remove the saml_session_index from the session' do
        expect(session[:saml_session_index]).to eq 'saml_session_index'
      end
    end

    shared_examples 'no change to to other providers in the session' do
      let(:provider) { 'another_provider' }

      before do
        session[:omniauth_provider] = provider
        session[:saml_uid] = 'saml_uid'
        session[:saml_session_index] = 'saml_session_index'
        delete :deauthorize, params: {provider: omniauth_provider}
      end

      it 'removes the provider from the session' do
        expect(session[:omniauth_provider]).to eq provider
      end

      it 'removes the saml_uid from the session' do
        expect(session[:saml_uid]).to eq 'saml_uid'
      end

      it 'removes the saml_session_index from the session' do
        expect(session[:saml_session_index]).to eq 'saml_session_index'
      end
    end

    shared_examples 'no addition of the provider to the session' do
      before do
        delete :deauthorize, params: {provider: omniauth_provider}
      end

      it 'does not add the provider to the session' do
        expect(session[:omniauth_provider]).to be_nil
      end

      it 'does not add the saml_uid to the session' do
        expect(session[:saml_uid]).to be_nil
      end

      it 'does not add the saml_session_index to the session' do
        expect(session[:saml_session_index]).to be_nil
      end
    end

    let(:user) { create(:user) }
    let(:identity) { create(:user_identity, user:, omniauth_provider:) }

    context 'when password is set and identity exists' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(user.identities).to receive(:find_by).with(omniauth_provider:).and_return(identity)
      end

      it 'destroys the identity' do
        expect(identity).to receive(:destroy)
        delete :deauthorize, params: {provider: omniauth_provider}
      end

      it 'decreases the identity count' do
        expect { delete :deauthorize, params: {provider: omniauth_provider} }.to change(UserIdentity, :count).by(-1)
      end

      it 'redirects to edit user registration path' do
        delete :deauthorize, params: {provider: omniauth_provider}
        expect(response).to redirect_to edit_user_registration_path
      end

      it 'sets a flash message' do
        delete :deauthorize, params: {provider: omniauth_provider}
        expect(flash[:notice]).to eq I18n.t('users.omni_auth.success_deauthorize', kind: OmniAuth::Utils.camelize(omniauth_provider))
      end

      context 'when session contains the provider' do
        before do
          session[:omniauth_provider] = omniauth_provider
          session[:saml_uid] = 'saml_uid'
          session[:saml_session_index] = 'saml_session_index'
          delete :deauthorize, params: {provider: omniauth_provider}
        end

        it 'removes the provider from the session' do
          expect(session[:omniauth_provider]).to be_nil
        end

        it 'removes the saml_uid from the session' do
          expect(session[:saml_uid]).to be_nil
        end

        it 'removes the saml_session_index from the session' do
          expect(session[:saml_session_index]).to be_nil
        end
      end

      it_behaves_like 'no change to to other providers in the session'
      it_behaves_like 'no addition of the provider to the session'
    end

    context 'when password is set but identity does not exist' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(user.identities).to receive(:find_by).with(omniauth_provider:).and_return(nil)
      end

      it 'does not destroy the identity' do
        expect(identity).not_to receive(:destroy)
        delete :deauthorize, params: {provider: omniauth_provider}
      end

      it 'redirects to edit user registration path' do
        delete :deauthorize, params: {provider: omniauth_provider}
        expect(response).to redirect_to edit_user_registration_path
      end

      it 'sets a flash message' do
        delete :deauthorize, params: {provider: omniauth_provider}
        expect(flash[:alert]).to eq I18n.t('users.omni_auth.failure_deauthorize_not_linked', kind: OmniAuth::Utils.camelize(omniauth_provider))
      end

      it_behaves_like 'no removal of affected provider in the session'
      it_behaves_like 'no change to to other providers in the session'
      it_behaves_like 'no addition of the provider to the session'
    end

    context 'when password exists but identity cannot be deleted' do
      let(:user_identity) { build(:user_identity, user:, omniauth_provider:, provider_uid: nil) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(user.identities).to receive(:find_by).with(omniauth_provider:).and_return(user_identity)
        user_identity.valid?
        allow(user_identity).to receive(:destroy).and_return(false)
      end

      it 'redirects to edit user registration path' do
        delete :deauthorize, params: {provider: omniauth_provider}
        expect(response).to redirect_to edit_user_registration_path
      end

      it 'sets a flash message' do
        delete :deauthorize, params: {provider: omniauth_provider}
        reason = "#{UserIdentity.human_attribute_name('provider_uid')} can't be blank"
        expect(flash[:alert]).to eq I18n.t('users.omni_auth.failure_deauthorize', kind: OmniAuth::Utils.camelize(omniauth_provider), reason:)
      end

      it_behaves_like 'no removal of affected provider in the session'
      it_behaves_like 'no change to to other providers in the session'
      it_behaves_like 'no addition of the provider to the session'
    end

    context 'when password is not set and last identity is deleted' do
      before do
        user.update(password_set: false)
        allow(controller).to receive(:current_user).and_return(user)
        allow(user.identities).to receive(:find_by).with(omniauth_provider:).and_return(identity)
      end

      it 'does not destroy the identity' do
        expect(identity).not_to receive(:destroy)
        delete :deauthorize, params: {provider: omniauth_provider}
      end

      it 'redirects to edit user registration path' do
        delete :deauthorize, params: {provider: omniauth_provider}
        expect(response).to redirect_to edit_user_registration_path
      end

      it 'sets a flash message' do
        delete :deauthorize, params: {provider: omniauth_provider}
        expect(flash[:alert]).to eq I18n.t('users.omni_auth.failure_deauthorize_last_identity', kind: OmniAuth::Utils.camelize(omniauth_provider))
      end

      it_behaves_like 'no removal of affected provider in the session'
      it_behaves_like 'no change to to other providers in the session'
      it_behaves_like 'no addition of the provider to the session'
    end
  end
end
