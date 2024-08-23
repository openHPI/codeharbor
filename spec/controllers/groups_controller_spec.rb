# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsController do
  include ActiveJob::TestHelper
  render_views

  let(:user) { create(:user, preferred_locale: user_locale) }
  let(:group_admin) { create(:user, preferred_locale: admin_locale) }

  let(:user_locale) { :en }
  let(:admin_locale) { :de }

  let(:valid_post_attributes) do
    build(:group, users: [user]).attributes.except('id', 'created_at', 'updated_at')
  end

  let(:invalid_attributes) do
    {name: ''}
  end
  let(:group_memberships) { [build(:group_membership, :with_admin, user: group_admin), build(:group_membership, user:)] }
  let!(:group) { create(:group, group_memberships:) }

  before { sign_in user }

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

    describe 'PATCH #remove_task' do
      let!(:group) { create(:group, group_memberships:, tasks:) }

      let(:tasks) { [task] }
      let(:task) { build(:task) }

      it 'removes specified task from the group' do
        expect { patch :remove_task, params: {id: group.to_param, task: task.id} }.to change(group.tasks, :count).by(-1)
      end

      it 'redirects to the groups list' do
        patch :remove_task, params: {id: group.to_param, task: task.id}
        expect(response).to redirect_to(group)
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

  describe 'POST #request_access' do
    subject(:post_request) { post :request_access, params: {id: group.to_param} }

    let(:group_memberships) { [build(:group_membership, :with_admin, user: group_admin)] }

    it 'translates access request message into correct language for recipient' do
      post_request
      expect(I18n.with_locale(admin_locale) { group_admin.received_messages.find_by(action: :group_request).text }).to eq(I18n.t('groups.messages.group_request', user: user.name, group: group.name, locale: admin_locale))
    end

    it 'sends mail in correct language for recipient' do
      perform_enqueued_jobs { post_request }
      expect(ActionMailer::Base.deliveries.last.body.parts.first.body).to include(I18n.t('groups.access_request_mailer.message_line2', locale: admin_locale))
    end
  end

  describe 'POST #grant_access' do
    subject(:post_request) { post :grant_access, params: {id: group.to_param, user:} }

    let(:group_memberships) { [build(:group_membership, :with_admin, user: group_admin)] }

    before do
      post :request_access, params: {id: group.to_param}
      sign_in group_admin
    end

    it 'adds user to group' do
      post_request
      expect(group.users).to include(user)
    end

    it 'translates access granted message into correct language for recipient' do
      post_request
      expect(I18n.with_locale(user_locale) { user.received_messages.find_by(action: :group_approval).text }).to eq(I18n.t('groups.messages.group_approval', user: group_admin.name, group: group.name, locale: user_locale))
    end
  end

  describe 'POST #deny_access' do
    subject(:post_request) { post :deny_access, params: {id: group.to_param, user:} }

    let(:group_memberships) { [build(:group_membership, :with_admin, user: group_admin)] }

    before do
      post :request_access, params: {id: group.to_param}
      sign_in group_admin
    end

    it 'does not add user to group' do
      post_request
      expect(group.users).not_to include(user)
    end

    it 'translates access denied message into correct language for recipient' do
      post_request
      expect(I18n.with_locale(user_locale) { user.received_messages.find_by(action: :group_rejection).text }).to eq(I18n.t('groups.messages.group_rejection', user: group_admin.name, group: group.name, locale: user_locale))
    end
  end
end
