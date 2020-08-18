# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collections', type: :request do
  context 'when logged in' do
    let(:user) { FactoryBot.create(:user) }
    let(:collection) { FactoryBot.create(:collection, title: 'Some Collection', users: [user], exercises: []) }
    let(:collection_params) { FactoryBot.attributes_for(:collection) }

    before do
      post login_path, params: {email: user.email, password: user.password}
      follow_redirect!
    end

    describe 'GET /collections' do
      it 'works! (now write some real specs)' do
        get collections_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /collections' do
      it 'has http 302' do
        post collections_path, params: {collection: collection_params}
        expect(response).to have_http_status(:found)
      end
    end

    describe 'GET /collections/new' do
      it 'has http 200' do
        get new_collection_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /collections/:id/edit' do
      it 'has http 200' do
        get edit_collection_path(collection)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /collection/:id' do
      it 'has http 200' do
        get collection_path(collection)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /collection/:id' do
      it 'has http 302' do
        patch collection_path(collection, collection: collection_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'PUT /collection/:id' do
      it 'has http 302' do
        put collection_path(collection, collection: collection_params)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
