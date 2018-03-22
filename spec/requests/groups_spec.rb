require 'rails_helper'

RSpec.describe "groups", type: :request do
  context 'logged in' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @group = FactoryBot.create(:group, users: [@user])
      @group.make_admin(@user)
      @group_params = FactoryBot.attributes_for(:group)
      post login_path, params: {:email => @user.email, :password => @user.password}
      follow_redirect!
    end

    describe "GET /groups" do
      it "works! (now write some real specs)" do
        get groups_path
        expect(response).to have_http_status(200)
      end
    end
    describe 'POST /groups' do
      it 'has http 302' do
        post groups_path, params: {group: @group_params}
        expect(response).to have_http_status(302)
      end
    end
    describe 'GET /groups/new' do
      it 'has http 200' do
        get new_group_path
        expect(response).to have_http_status(200)
      end
    end
    describe 'GET /groups/:id/edit' do
      it 'has http 200' do
        get edit_group_path(@group)
        expect(response).to have_http_status(200)
      end
    end
    describe 'GET /group/:id' do
      it 'has http 302' do
        get group_path(@group)
        expect(response).to have_http_status(200)
      end
    end
    describe 'PATCH /group/:id' do
      it 'has http 302' do
        patch group_path(@group, group: @group_params)
        expect(response).to have_http_status(302)
      end
    end
    describe 'PUT /group/:id' do
      it 'has http 302' do
        put group_path(@group, group: @group_params)
        expect(response).to have_http_status(302)
      end
    end
    describe 'DELETE /group/:id' do
      it 'has http 302' do
        delete group_path(@group)
        expect(response).to have_http_status(302)
      end
    end
  end
end