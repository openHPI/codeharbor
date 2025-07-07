# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collections' do
  context 'when logged in' do
    let(:user) { create(:user) }
    let(:task) { create(:task) }
    let(:collection) { create(:collection, title: 'Some Collection', users: [user], tasks: [task]) }
    let(:collection_params) { build(:collection).attributes.except('id', 'created_at', 'updated_at') }

    before do
      sign_in user
    end

    describe 'GET /collections' do
      it 'works! (now write some real specs)' do
        get collections_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /collections' do
      it 'responds with status 303' do
        post collections_path, params: {collection: collection_params}
        expect(response).to have_http_status(:see_other)
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
      it 'responds with status 303' do
        patch collection_path(collection, collection: collection_params)
        expect(response).to have_http_status(:see_other)
      end
    end

    describe 'PUT /collection/:id' do
      it 'responds with status 303' do
        put collection_path(collection, collection: collection_params)
        expect(response).to have_http_status(:see_other)
      end
    end

    describe 'POST /collection/:id/remove_task/:task_id' do
      it 'responds with status 303' do
        patch remove_task_collection_path(collection, collection:, task:)
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
