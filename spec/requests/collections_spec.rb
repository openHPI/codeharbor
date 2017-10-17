require 'rails_helper'

RSpec.describe "Collections", type: :request do
  context 'logged in' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @collection = FactoryGirl.create(:collection, title: 'Some Collection', users: [@user], exercises: [])
      @collection_params = FactoryGirl.attributes_for(:collection)
      post_via_redirect login_path, :email => @user.email, :password => @user.password
    end

    describe "GET /collections" do
      it "works! (now write some real specs)" do
        get collections_path
        expect(response).to have_http_status(200)
      end
    end
    describe 'POST /collections' do
      it 'has http 302' do
        post collections_path,{collection: @collection_params}
        expect(response).to have_http_status(302)
      end
    end
    describe 'GET /collections/new' do
      it 'has http 200' do
        get new_collection_path
        expect(response).to have_http_status(200)
      end
    end
    describe 'GET /collections/:id/edit' do
      it 'has http 200' do
        get edit_collection_path(@collection)
        expect(response).to have_http_status(200)
      end
    end
    describe 'GET /collection/:id' do
      it 'has http 200' do
        get collection_path(@collection)
        expect(response).to have_http_status(200)
      end
    end
    describe 'PATCH /collection/:id' do
      it 'has http 302' do
        patch collection_path(@collection, collection: @collection_params)
        expect(response).to have_http_status(302)
      end
    end
    describe 'PUT /collection/:id' do
      it 'has http 302' do
        put collection_path(@collection, collection: @collection_params)
        expect(response).to have_http_status(302)
      end
    end
    describe 'DELETE /collection/:id' do
      it 'has http 200' do
        delete collection_path(@collection)
        expect(response).to have_http_status(302)
      end
    end
  end
end
