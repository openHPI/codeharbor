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
