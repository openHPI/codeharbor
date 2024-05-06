# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users' do
  let(:user) { create(:user) }

  context 'when not logged in' do
    describe '/users/sign_in' do
      it 'returns http 200' do
        post user_session_path, params: {email: user.email, password: user.password}
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'when logged in' do
    let(:user_params) { attributes_for(:user, current_password: user.password) }

    before do
      sign_in user
    end

    describe 'GET /users/sign_up' do
      it 'returns http 302' do
        get new_user_registration_path
        expect(response).to have_http_status(:found)
      end
    end

    describe 'GET /users/edit' do
      it 'returns http 200' do
        get edit_user_registration_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /users/:id' do
      it 'returns http 200' do
        get user_path(user)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /users' do
      it 'returns http 302' do
        patch user_registration_path(user, user: user_params, format: :html)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'PUT /users' do
      it 'returns http 302' do
        put user_registration_path(user, user: user_params, format: :html)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'DELETE /users' do
      it 'returns http 302' do
        delete user_registration_path(user, format: :html)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
