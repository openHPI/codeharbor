# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Groups' do
  context 'when logged in' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:group_params) { build(:group).attributes.except('id', 'created_at', 'updated_at') }

    before do
      group.add(user, role: :admin)
      sign_in user
    end

    describe 'GET /groups' do
      it 'works! (now write some real specs)' do
        get groups_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /groups' do
      it 'has http 302' do
        post groups_path, params: {group: group_params}
        expect(response).to have_http_status(:found)
      end
    end

    describe 'GET /groups/new' do
      it 'has http 200' do
        get new_group_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /groups/:id/edit' do
      it 'has http 200' do
        get edit_group_path(group)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /group/:id' do
      it 'has http 200' do
        get group_path(group)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /group/:id' do
      it 'has http 302' do
        patch group_path(group, group: group_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'PUT /group/:id' do
      it 'has http 302' do
        put group_path(group, group: group_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'DELETE /group/:id' do
      it 'has http 302' do
        delete group_path(group)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
