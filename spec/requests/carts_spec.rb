require 'rails_helper'

RSpec.describe 'Carts', type: :request do
  context 'when logged in' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart, user: @user)
      post_via_redirect login_path, :email => @user.email, :password => @user.password
    end
    describe 'GET /carts' do
      it 'has http 200' do
        get carts_path
        expect(response).to have_http_status(302)
      end
    end
    describe 'POST /carts' do
      it 'has http 302' do
        post carts_path
        expect(response).to have_http_status(302)
      end
    end
    describe 'GET /carts/new' do
      it 'has http 200' do
        get new_cart_path
        expect(response).to have_http_status(200)
      end
    end
    describe 'GET /carts/:id/edit' do
      it 'has http 200' do
        get edit_cart_path(@cart)
        expect(response).to have_http_status(302)
      end
    end
    describe 'GET /cart/:id' do
      it 'has http 200' do
        get cart_path(@cart)
        expect(response).to have_http_status(200)
      end
    end
    describe 'PATCH /cart/:id' do
      it 'has http 200' do
        patch cart_path(@cart)
        expect(response).to have_http_status(302)
      end
    end
    describe 'PUT /cart/:id' do
      it 'has http 200' do
        put cart_path(@cart)
        expect(response).to have_http_status(302)
      end
    end
    describe 'DELETE /cart/:id' do
      it 'has http 302' do
        delete cart_path(@cart)
        expect(response).to have_http_status(302)
      end
    end
  end
end
