# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users', type: :request do
  context 'when logged in' do
    let(:user) { FactoryBot.create(:user) }
    let(:user_params) { FactoryBot.attributes_for(:user) }

    before do
      post login_path, params: {email: user.email, password: user.password}
      follow_redirect!
    end

    describe 'GET /users' do
      it 'redirects to root' do
        get users_path
        expect(response).to redirect_to '/'
      end

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it 'has http 200' do
          get users_path
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe 'POST /users' do
      it 'has http 302' do
        post users_path, params: {user: user_params}
        expect(response).to have_http_status(:found)
      end
    end

    describe 'GET /users/new' do
      it 'has http 200' do
        get new_user_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /users/:id/edit' do
      it 'has http 200' do
        get edit_user_path(user)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /user/:id' do
      it 'has http 302' do
        get user_path(user)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /user/:id' do
      it 'has http 302' do
        patch user_path(user, user: user_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'PUT /user/:id' do
      it 'has http 302' do
        put user_path(user, user: user_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'DELETE /user/:id' do
      it 'has http 302' do
        delete user_path(user)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
