# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::PasswordsController do
  render_views

  let(:user) { create(:user, reset_password_token: reset_password_token_for_db, reset_password_sent_at: Time.zone.now) }
  let(:new_password) { 'new_password' }
  let(:reset_password_token) { Devise.friendly_token }
  let(:reset_password_token_for_db) { Devise.token_generator&.digest(User, :reset_password_token, reset_password_token) }

  before do
    user.save
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  shared_examples 'a successful password update' do
    before do
      put :update, params: {user: {password: new_password, password_confirmation: new_password, reset_password_token:}}
    end

    it 'sets the password_set attribute to true' do
      expect(user.reload.password_set).to be true
    end

    it 'updates the password' do
      expect(user.reload.valid_password?(new_password)).to be true
    end
  end

  shared_examples 'a failed password update' do
    before do
      put :update, params: {user: {password: new_password, password_confirmation: 'mistyped_password', reset_password_token:}}
    end

    it 'does not change the password_set attribute' do
      expect(user.reload.password_set).to be password_set
    end

    it 'does not update the password' do
      expect(user.reload.valid_password?(new_password)).to be false
    end
  end

  describe '#update' do
    context 'when no password is set yet (i.e., for OmniAuth users)' do
      let(:password_set) { false }

      before { user.update(password_set:) }

      it_behaves_like 'a successful password update'
      it_behaves_like 'a failed password update'
    end

    context 'when password is already set' do
      let(:password_set) { true }

      it_behaves_like 'a successful password update'
      it_behaves_like 'a failed password update'
    end
  end
end
