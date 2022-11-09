# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsController do
  let(:user) { create(:user) }

  let(:valid_post_attributes) do
    attributes_for(:group, users: [user])
  end

  let(:invalid_attributes) do
    {name: ''}
  end

  let!(:group) { create(:group) }

  before do
    sign_in user
    group.grant_access(user)
  end

  describe 'GET #index' do
    it 'assigns all groups as @groups' do
      get :index, params: {}
      expect(assigns(:groups)).to eq([group])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested group as @group' do
      get :show, params: {id: group.to_param}
      expect(assigns(:group)).to eq(group)
    end
  end

  describe 'GET #new' do
    it 'assigns a new group as @group' do
      get :new, params: {}
      expect(assigns(:group)).to be_a_new(Group)
    end
  end

  context 'when user is admin of group' do
    before { group.make_admin(user) }

    describe 'GET #edit' do
      it 'assigns the requested group as @group' do
        get :edit, params: {id: group.to_param}
        expect(assigns(:group)).to eq(group)
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          {name: 'new name'}
        end

        it 'updates the requested group' do
          expect { put :update, params: {id: group.to_param, group: new_attributes} }
            .to change { group.reload.name }.to('new name')
        end

        it 'assigns the requested group as @group' do
          put :update, params: {id: group.to_param, group: new_attributes}
          expect(assigns(:group)).to eq(group)
        end

        it 'redirects to the group' do
          put :update, params: {id: group.to_param, group: new_attributes}
          expect(response).to redirect_to(group)
        end
      end

      context 'with invalid params' do
        it 'assigns the group as @group' do
          put :update, params: {id: group.to_param, group: invalid_attributes}
          expect(assigns(:group)).to eq(group)
        end

        it "re-renders the 'edit' template" do
          put :update, params: {id: group.to_param, group: invalid_attributes}
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested group' do
        expect do
          delete :destroy, params: {id: group.to_param}
        end.to change(Group, :count).by(-1)
      end

      it 'redirects to the groups list' do
        delete :destroy, params: {id: group.to_param}
        expect(response).to redirect_to(groups_url)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Group' do
        expect do
          post :create, params: {group: valid_post_attributes}
        end.to change(Group, :count).by(1)
      end

      it 'assigns a newly created group as @group' do
        post :create, params: {group: valid_post_attributes}
        expect(assigns(:group)).to be_a(Group)
      end

      it 'persists @group' do
        post :create, params: {group: valid_post_attributes}
        expect(assigns(:group)).to be_persisted
      end

      it 'redirects to the created group' do
        post :create, params: {group: valid_post_attributes}
        expect(response).to redirect_to(Group.last)
      end

      it 'adds user as admin to the group' do
        post :create, params: {group: valid_post_attributes}
        expect(Group.last.admin?(user)).to be true
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved group as @group' do
        post :create, params: {group: invalid_attributes}
        expect(assigns(:group)).to be_a_new(Group)
      end

      it "re-renders the 'new' template" do
        post :create, params: {group: invalid_attributes}
        expect(response).to render_template('new')
      end
    end
  end
end
