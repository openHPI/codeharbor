# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsController do
  render_views

  let(:valid_attributes) do
    attributes_for(:collection)
  end

  let(:invalid_attributes) do
    {title: ''}
  end

  let(:user) { create(:user) }

  before do
    sign_in user
    request.headers[:referer] = collections_url
  end

  describe 'GET #index' do
    let!(:collection) { create(:collection, valid_attributes.merge(users: [user])) }

    it 'assigns all collections as @collections' do
      get :index, params: {}
      expect(assigns(:collections)).to include collection
    end
  end

  describe 'GET #show' do
    let(:task) { create(:task) }
    let(:collection) { create(:collection, valid_attributes.merge(users: [user], tasks: [task])) }

    it 'assigns the requested collection as @collection' do
      get :show, params: {id: collection.to_param}
      expect(assigns(:collection)).to eq(collection)
    end

    it 'includes a link to the respective tasks' do
      get :show, params: {id: collection.to_param}
      expect(response.body).to include(task_path(collection.tasks.first))
    end
  end

  describe 'GET #new' do
    it 'assigns a new collection as @collection' do
      get :new, params: {}
      expect(assigns(:collection)).to be_a_new(Collection)
    end
  end

  describe 'GET #edit' do
    let(:collection) { create(:collection, valid_attributes.merge(users: [user])) }

    it 'assigns the requested collection as @collection' do
      get :edit, params: {id: collection.to_param}
      expect(assigns(:collection)).to eq(collection)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Collection' do
        expect do
          post :create, params: {collection: valid_attributes}
        end.to change(Collection, :count).by(1)
      end

      it 'assigns a newly created collection as @collection' do
        post :create, params: {collection: valid_attributes}
        expect(assigns(:collection)).to be_a(Collection)
      end

      it 'persists @collection' do
        post :create, params: {collection: valid_attributes}
        expect(assigns(:collection)).to be_persisted
      end

      it 'redirects to the created collection' do
        post :create, params: {collection: valid_attributes}
        expect(response).to redirect_to(collections_path)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved collection as @collection' do
        post :create, params: {collection: invalid_attributes}
        expect(assigns(:collection)).to be_a_new(Collection)
      end

      it "re-renders the 'new' template" do
        post :create, params: {collection: invalid_attributes}
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    let(:collection) { create(:collection, valid_attributes.merge(users: [user])) }

    context 'with valid params' do
      let(:new_attributes) do
        {title: 'new title'}
      end

      it 'updates the requested collection' do
        expect do
          put :update, params: {id: collection.to_param, collection: new_attributes}
        end.to change { collection.reload.title }.to('new title')
      end

      it 'assigns the requested collection as @collection' do
        put :update, params: {id: collection.to_param, collection: valid_attributes}
        expect(assigns(:collection)).to eq(collection)
      end

      it 'redirects to the collection' do
        put :update, params: {id: collection.to_param, collection: valid_attributes}
        expect(response).to redirect_to(collections_path)
      end
    end

    context 'with invalid params' do
      it 'assigns the collection as @collection' do
        put :update, params: {id: collection.to_param, collection: invalid_attributes}
        expect(assigns(:collection)).to eq(collection)
      end

      it "re-renders the 'edit' template" do
        put :update, params: {id: collection.to_param, collection: invalid_attributes}
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'PATCH #remove_task' do
    let(:collection) { create(:collection, valid_attributes.merge(users: [user])) }
    let!(:task) { create(:task, collections: [collection]) }
    let(:patch_request) { patch :remove_task, params: {id: collection.id, task: task.id} }

    it 'removes task from collection' do
      expect { patch_request }.to change(collection.reload.tasks, :count).by(-1)
    end
  end

  describe 'PATCH #remove_all' do
    let(:collection) { create(:collection, valid_attributes.merge(users: [user], tasks:)) }
    let(:tasks) { create_list(:task, 2) }

    let(:patch_request) { patch :remove_all, params: {id: collection.id} }

    it 'removes task from collection' do
      expect { patch_request }.to change(collection.tasks, :count).by(-2)
    end
  end

  describe 'GET #download_all' do
    let(:collection) { create(:collection, valid_attributes.merge(users: [user], tasks:)) }
    let(:tasks) { create_list(:task, 2) }
    let(:zip) { instance_double(StringIO, string: 'dummy') }

    let(:get_request) { get :download_all, params: {id: collection.id} }

    before { allow(ProformaService::ExportTasks).to receive(:call).with(tasks: collection.reload.tasks).and_return(zip) }

    it do
      get_request
      expect(ProformaService::ExportTasks).to have_received(:call)
    end

    it 'sends the correct data' do
      get_request
      expect(response.body).to eql 'dummy'
    end

    it 'sets the correct Content-Type header' do
      get_request
      expect(response.header['Content-Type']).to eql 'application/zip'
    end

    it 'sets the correct Content-Disposition header' do
      get_request
      expect(response.header['Content-Disposition']).to include "attachment; filename=\"#{collection.title}.zip\""
    end
  end

  describe 'POST #share' do
    let(:collection) { create(:collection, valid_attributes.merge(users: [user])) }
    let(:post_request) { post :share, params: }
    let(:params) { {id: collection.id, user: create(:user).email} }

    it 'creates a message' do
      expect { post_request }.to change(Message, :count).by(1)
    end

    it 'redirects to collection' do
      post_request
      expect(response).to redirect_to collection
    end

    it 'sets flash message' do
      expect(post_request.request.flash[:notice]).to eql I18n.t('controllers.collections.share.notice')
    end

    context 'when no email is given' do
      let(:params) { {id: collection.id} }

      it 'does not create a message' do
        expect { post_request }.not_to change(Message, :count)
      end

      it 'redirects to collection' do
        post_request
        expect(response).to redirect_to collection
      end

      it 'sets flash message' do
        expect(post_request.request.flash[:alert]).to eql I18n.t('controllers.collections.share.alert')
      end
    end
  end

  describe 'POST #view_shared' do
    let(:collection_owner) { create(:user) }
    let(:collection) { create(:collection, valid_attributes.merge(users: [collection_owner, user])) }
    let(:get_request) { get :view_shared, params: }
    let(:params) { {id: collection.id, user: collection_owner.id} }

    context 'when user has been invited' do
      it 'assigns collection' do
        get_request
        expect(assigns(:collection)).to eq(collection)
      end

      it 'renders show' do
        get_request
        expect(response).to render_template('show')
      end

      it 'renders the page successfully' do
        get_request
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user has not been invited' do
      let(:collection) { create(:collection, valid_attributes.merge(users: [collection_owner])) }

      it 'does not show the page' do
        get_request
        expect(response).not_to render_template('show')
      end

      it 'redirects the user to the collections path' do
        get_request
        expect(response).to redirect_to collections_path
      end
    end
  end

  describe 'POST #save_shared' do
    let(:collection) { create(:collection, valid_attributes.merge(users: create_list(:user, 1))) }
    let(:post_request) { post :save_shared, params: }
    let(:params) { {id: collection.id} }

    context 'when user has been invited' do
      let(:send_invitation) do
        create(:message, sender: collection.users.first, recipient: user, param_type: 'collection', param_id: collection.id,
          text: 'Invitation')
      end

      it 'increases usercount of collection' do
        send_invitation
        expect { post_request }.to change(collection.reload.users, :count).from(1).to(2)
      end

      it 'adds user to collection' do
        send_invitation
        post_request
        expect(collection.reload.users).to include user
      end

      it 'redirects to collection' do
        send_invitation
        post_request
        expect(response).to redirect_to collection
      end
    end

    context 'when user has not been invited' do
      it 'does not increase usercount of collection' do
        expect { post_request }.not_to change(collection.reload.users, :count)
      end

      it 'does not add the user to the collection' do
        post_request
        expect(collection.reload.users).not_to include user
      end

      it 'redirects to collection' do
        post_request
        expect(response).to redirect_to collections_path
      end
    end
  end

  describe 'POST #leave' do
    let!(:collection) { create(:collection, valid_attributes.merge(users:)) }
    let(:users) { [create(:user), user] }
    let(:post_request) { post :leave, params: }
    let(:params) { {id: collection.id} }

    it 'removes user from collection' do
      post_request
      expect(collection.reload.users).not_to include user
    end

    it 'decreases usercount of collection' do
      expect { post_request }.to change(collection.reload.users, :count).from(2).to(1)
    end

    it 'redirects to the collections list' do
      post_request
      expect(response).to redirect_to(collections_url)
    end

    context 'when there is only one user in collection' do
      let(:users) { [user] }

      it 'deletes collection' do
        expect { post_request }.to change(Collection, :count).by(-1)
      end

      it 'redirects to the collections list' do
        post_request
        expect(response).to redirect_to(collections_url)
      end
    end
  end

  # post push_collection later
  # get collections_all # adminview
end
