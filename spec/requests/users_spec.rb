require 'rails_helper'

RSpec.describe 'users', type: :request do
  context 'when logged in' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @user_params = FactoryBot.attributes_for(:user)
      post login_path, params: {:email => @user.email, :password => @user.password}
      follow_redirect!
    end
    describe 'GET /users' do
      it 'has http 200' do
        get users_path
        expect(response).to have_http_status(200)
      end
    end
    describe 'POST /users' do
      it 'has http 302' do
        post users_path, params: {user: @user_params}
        expect(response).to have_http_status(302)
      end
    end
    describe 'GET /users/new' do
      it 'has http 200' do
        get new_user_path
        expect(response).to have_http_status(200)
      end
    end
    describe 'GET /users/:id/edit' do
      it 'has http 200' do
        get edit_user_path(@user)
        expect(response).to have_http_status(200)
      end
    end
    describe 'GET /user/:id' do
      it 'has http 302' do
        get user_path(@user)
        expect(response).to have_http_status(200)
      end
    end
    describe 'PATCH /user/:id' do
      it 'has http 302' do
        patch user_path(@user, user: @user_params)
        expect(response).to have_http_status(302)
      end
    end
    describe 'PUT /user/:id' do
      it 'has http 302' do
        put user_path(@user, user: @user_params)
        expect(response).to have_http_status(302)
      end
    end
    describe 'DELETE /user/:id' do
      it 'has http 302' do
        delete user_path(@user)
        expect(response).to have_http_status(302)
      end
    end
  end
end
