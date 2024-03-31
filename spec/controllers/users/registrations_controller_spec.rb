# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegistrationsController do
  render_views

  let(:user) { create(:user) }
  let(:new_password) { 'new_password' }
  let(:new_first_name) { 'New Name' }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#edit' do
    before { sign_in user }

    it 'renders the edit template' do
      get :edit
      expect(response).to render_template(:edit)
    end

    it 'does not offer to manage OmniAuth accounts' do
      get :edit
      expect(response.body).not_to include(I18n.t('users.registrations.edit.manage_omniauth'))
    end

    context 'with an available identity provider' do
      let(:provider) { :provider }

      before do
        # Add a new provider to the omniauth config, reload routes, and make the URL helpers available
        Devise.omniauth provider
        Rails.application.reload_routes!
        Devise.include_helpers(Devise::OmniAuth)
      end

      after do
        # Remove the provider from the omniauth config, reload routes
        Devise.class_variable_set(:@@omniauth_configs, {}) # rubocop:disable Style/ClassVars
        Rails.application.reload_routes!
        # The URL helpers cannot be removed, but this only affects methods from Devise::OmniAuth::UrlHelpers.
        # Those methods won't be called successfully without the provider in the omniauth config, so that this is fine.
      end

      it 'offers to manage OmniAuth accounts' do
        get :edit
        expect(response.body).to include(I18n.t('users.registrations.edit.manage_omniauth', kind: OmniAuth::Utils.camelize(provider)))
      end

      context 'when no identity is linked' do
        it 'does not offer to unlink the identity' do
          get :edit
          expect(response.body).not_to include(I18n.t('users.registrations.edit.remove_identity', kind: OmniAuth::Utils.camelize(provider)))
        end

        it 'offers to add the identity' do
          get :edit
          expect(response.body).to include(I18n.t('users.registrations.edit.add_identity', kind: OmniAuth::Utils.camelize(provider)))
        end

        it 'does not explain that the last identity cannot be removed' do
          get :edit
          expect(response.body).not_to include(I18n.t('users.registrations.edit.cannot_remove_last_identity', kind: OmniAuth::Utils.camelize(provider)))
        end
      end

      context 'when an existing identity is linked' do
        before { create(:user_identity, user:, omniauth_provider: provider) }

        it 'offers to unlink the identity' do
          get :edit
          expect(response.body).to include(I18n.t('users.registrations.edit.remove_identity', kind: OmniAuth::Utils.camelize(provider)))
        end

        it 'does not offer to add the identity' do
          get :edit
          expect(response.body).not_to include(I18n.t('users.registrations.edit.add_identity', kind: OmniAuth::Utils.camelize(provider)))
        end

        it 'does not explain that the last identity cannot be removed' do
          get :edit
          expect(response.body).not_to include(I18n.t('users.registrations.edit.cannot_remove_last_identity', kind: OmniAuth::Utils.camelize(provider)))
        end

        context 'when no password is set' do
          before { user.update(password_set: false) }

          it 'does not offer to unlink the identity' do
            get :edit
            expect(response.body).not_to include(I18n.t('users.registrations.edit.remove_identity', kind: OmniAuth::Utils.camelize(provider)))
          end

          it 'does not offer to add the identity' do
            get :edit
            expect(response.body).not_to include(I18n.t('users.registrations.edit.add_identity', kind: OmniAuth::Utils.camelize(provider)))
          end

          it 'explains that the last identity cannot be removed' do
            get :edit
            expect(response.body).to include(I18n.t('users.registrations.edit.cannot_remove_last_identity', kind: OmniAuth::Utils.camelize(provider)))
          end
        end
      end
    end
  end

  describe '#update' do
    context 'when avatar was removed' do
      before { user.avatar.attach(io: Rails.root.join('spec/fixtures/files/red.bmp').open, filename: 'red.bmp') }

      it 'purges the avatar' do
        sign_in user
        put :update, params: {user: {avatar_present: 'false'}}
        expect(user.reload.avatar.attached?).to be false
      end
    end

    context 'when no password is set yet (i.e., for OmniAuth users)' do
      before { user.update(password_set: false) }

      context 'when a user attempted to set a password but failed' do
        before do
          sign_in user
          put :update, params: {user: {first_name: new_first_name, password: new_password, password_confirmation: 'mistyped_new_password'}}
        end

        it 'does not require the current_password' do
          expect(response.body).not_to include(I18n.t('activerecord.attributes.user.current_password'))
        end

        it 'does not change the password_set flag' do
          expect(user.reload.password_set).to be false
        end

        it 'does not update the password' do
          expect(user.reload.valid_password?(new_password)).to be false
        end

        it 'does not update to the new name' do
          expect(user.reload.first_name).not_to eq new_first_name
        end
      end

      context 'when a user successfully sets a password' do
        before do
          sign_in user
          put :update, params: {user: {first_name: new_first_name, password: new_password, password_confirmation: new_password}}
        end

        it 'requires the current_password' do
          # We need to sign in again as the user changed. This is a Devise limitation.
          sign_in user.reload
          get :edit
          expect(response.body).to include(I18n.t('activerecord.attributes.user.current_password'))
        end

        it 'changes the password_set flag' do
          expect(user.reload.password_set).to be true
        end

        it 'updates the password' do
          expect(user.reload.valid_password?(new_password)).to be true
        end

        it 'updates to the new name' do
          expect(user.reload.first_name).to eq new_first_name
        end
      end

      context 'when a user updates without a password' do
        before do
          sign_in user
          put :update, params: {user: {first_name: new_first_name}}
        end

        it 'does not require the current_password' do
          # We need to sign in again as the user changed. This is a Devise limitation.
          sign_in user.reload
          get :edit
          expect(response.body).not_to include(I18n.t('activerecord.attributes.user.current_password'))
        end

        it 'does not change the password_set flag' do
          expect(user.reload.password_set).to be false
        end

        it 'does not update the password' do
          expect(user.reload.valid_password?(new_password)).to be false
        end

        it 'updates to the new name' do
          expect(user.reload.first_name).to eq new_first_name
        end
      end
    end

    context 'when a password is already set' do
      context 'when the user updates with their current password' do
        before do
          sign_in user
          put :update, params: {user: {first_name: new_first_name, password: new_password, password_confirmation: new_password, current_password: user.password}}
        end

        it 'requires the current_password' do
          # We need to sign in again as the user changed. This is a Devise limitation.
          sign_in user.reload
          get :edit
          expect(response.body).to include(I18n.t('activerecord.attributes.user.current_password'))
        end

        it 'updates the password' do
          expect(user.reload.valid_password?(new_password)).to be true
        end

        it 'does not modify the password_set flag' do
          expect(user.reload.password_set).to be true
        end

        it 'updates to the new name' do
          expect(user.reload.first_name).to eq new_first_name
        end
      end

      context 'when the user updates without their current password' do
        before do
          sign_in user
          put :update, params: {user: {first_name: new_first_name}}
        end

        it 'requires the current_password' do
          expect(response.body).to include(I18n.t('activerecord.attributes.user.current_password'))
        end

        it 'does not update the password' do
          expect(user.reload.valid_password?(new_password)).to be false
        end

        it 'does not modify the password_set flag' do
          expect(user.reload.password_set).to be true
        end

        it 'does not update to the new name' do
          expect(user.reload.first_name).not_to eq new_first_name
        end
      end
    end
  end
end
