# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController do
  render_views

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:valid_session) { {user_id: user.id} }
  let(:get_request) { get :show, params: {id: user_id} }

  describe 'GET #show' do
    shared_examples 'redirects with a flash message' do
      it 'redirects to the desired target' do
        get_request
        expect(response).to redirect_to(redirect_target)
      end

      it 'displays an error message' do
        expect { get_request }.to change { flash[:alert] }.to(desired_message)
      end
    end

    context 'when a user is signed in' do
      before { sign_in user }

      let(:redirect_target) { user_path(user) }

      it 'assigns the requested user as @user' do
        get :show, params: {id: user.to_param}, session: valid_session
        expect(assigns(:user)).to eq(user)
      end

      context 'when the requested user exists' do
        let(:user_id) { another_user.id }
        let(:desired_message) { I18n.t('common.errors.not_authorized') }

        it_behaves_like 'redirects with a flash message'
      end

      context 'when the requested user does not exist' do
        let(:user_id) { -1 }
        let(:desired_message) { I18n.t('common.errors.not_authorized') }

        it_behaves_like 'redirects with a flash message'

        context 'when accessing user is admin' do
          let(:user) { create(:admin) }
          let(:desired_message) { I18n.t('common.errors.not_found_error') }

          it_behaves_like 'redirects with a flash message'
        end
      end
    end

    context 'when a user is not signed in' do
      let(:redirect_target) { root_path }
      let(:desired_message) { I18n.t('common.errors.not_authorized') }

      context 'when the requested user exists' do
        let(:user_id) { another_user.id }

        it_behaves_like 'redirects with a flash message'
      end

      context 'when the requested user does not exist' do
        let(:user_id) { -1 }

        it_behaves_like 'redirects with a flash message'
      end
    end
  end
end
