# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Carts', type: :request do
  context 'when logged in' do
    let(:user) { FactoryBot.create(:user) }
    let(:cart) { FactoryBot.create(:cart, user: user) }

    before do
      post login_path, params: {email: user.email, password: user.password}
      follow_redirect!
    end

    describe 'GET /carts' do
      it 'has http 200' do
        get carts_path
        expect(response).to have_http_status(:found)
      end
    end

    describe 'POST /carts' do
      it 'has http 302' do
        post carts_path
        expect(response).to have_http_status(:found)
      end
    end

    describe 'GET /carts/new' do
      it 'has http 200' do
        get new_cart_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /carts/:id/edit' do
      it 'has http 200' do
        get edit_cart_path(cart)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'GET /cart/:id' do
      it 'has http 200' do
        get cart_path(cart)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /cart/:id' do
      it 'has http 200' do
        patch cart_path(cart)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'PUT /cart/:id' do
      it 'has http 200' do
        put cart_path(cart)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'DELETE /cart/:id' do
      it 'has http 302' do
        delete cart_path(cart)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
