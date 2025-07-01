# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsController do
  render_views

  let(:valid_attributes) do
    build(:collection).attributes.except('id', 'created_at', 'updated_at')
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
    subject(:get_request) { get :index, params: {option:} }

    let(:users) { [user] }
    let(:favorite_users) { [create(:user)] }
    let(:option) { 'mine' }
    let(:favorite_visibility_level) { :public }
    let!(:own_collection) { create(:collection, valid_attributes.merge(users:, visibility_level: :public)) }
    let!(:favorite_collection) { create(:collection, valid_attributes.merge(users: favorite_users, user_favorites: users, visibility_level: favorite_visibility_level)) }
    let!(:public_collection) { create(:collection, valid_attributes.merge(visibility_level: :public)) }

    before { create(:collection, valid_attributes.merge(visibility_level: :private)) }

    it 'assigns correct collection to @collections' do
      get_request
      expect(assigns(:collections)).to contain_exactly(own_collection)
    end

    it 'renders correct actions-buttons' do
      get_request
      expect(response.body).to include(I18n.t('common.button.view')).and(include(I18n.t('common.button.edit')))
    end

    context 'when user is not in collection' do
      let(:users) { [create(:user)] }

      it 'does add collection to @collections' do
        get_request
        expect(assigns(:collections)).not_to include own_collection
      end
    end

    context 'when option is favorite' do
      let(:option) { 'favorites' }

      it 'assigns favorite_collection as @collections' do
        get_request
        expect(assigns(:collections)).to contain_exactly(favorite_collection)
      end

      it 'renders correct actions-buttons' do
        get_request
        expect(response.body).to include(I18n.t('common.button.view')).and(not_include(I18n.t('common.button.edit')))
      end

      context 'when favorite_collection is private' do
        let(:favorite_visibility_level) { :private }

        it 'does not add favorite_collection to @collections' do
          get_request
          expect(assigns(:collections)).not_to include favorite_collection
        end

        context 'when user is in favorite_collection' do
          let(:favorite_users) { users }

          it 'assigns favorite_collection as @collections' do
            get_request
            expect(assigns(:collections)).to contain_exactly(favorite_collection)
          end
        end
      end
    end

    context 'when option is public' do
      let(:option) { 'public' }

      it 'assigns all collections as @collections' do
        get_request
        expect(assigns(:collections)).to contain_exactly(own_collection, favorite_collection, public_collection)
      end
    end
  end

  describe 'GET #show' do
    let(:task) { create(:task) }
    let(:collection) { create(:collection, valid_attributes.merge(users: [user], tasks: [task])) }

    it 'assigns the requested collection as @collection' do
      get :show, params: {id: collection.to_param}
      expect(assigns(:collection)).to eq(collection)
    end

    it 'assigns the correct number to @num_of_invites' do
      get :show, params: {id: collection.to_param}
      expect(assigns(:num_of_invites)).to eq(0)
    end

    it 'includes a link to the respective tasks' do
      get :show, params: {id: collection.to_param}
      expect(response.body).to include(task_path(collection.tasks.first))
    end

    it 'includes the correct visibility subinfo' do
      get :show, params: {id: collection.to_param}
      expect(response.body).to include(I18n.t('collections.show.visibility.private')).and(include(I18n.t('collections.show.num_of_other_users', count: 0)))
    end

    it 'includes the correct other-user subinfo' do
      get :show, params: {id: collection.to_param}
      expect(response.body).to include(I18n.t('collections.show.num_of_other_users', count: 0))
    end

    context 'when there are pending invites' do
      before do
        create(:message, sender: user, recipient: create(:user), action: :collection_shared, attachment: collection, text: 'Invitation')
      end

      let!(:message) { create(:message, sender: user, recipient: create(:user), action: :collection_shared, attachment: collection, text: 'Invitation') }

      it 'assigns the correct number to @num_of_invites' do
        get :show, params: {id: collection.to_param}
        expect(assigns(:num_of_invites)).to eq(2)
      end

      context 'when one of the invitations is deleted' do
        before do
          message.mark_as_deleted(message.recipient)
          message.save
        end

        it 'assigns the correct number to @num_of_invites' do
          get :show, params: {id: collection.to_param}
          expect(assigns(:num_of_invites)).to eq(1)
        end
      end
    end

    context 'when collection is public' do
      before { collection.update(visibility_level: :public) }

      it 'includes the correct visibility subinfo' do
        get :show, params: {id: collection.to_param}
        expect(response.body).to include(I18n.t('collections.show.visibility.public'))
      end
    end

    context 'when collection has other users' do
      before { collection.users << create(:user) }

      it 'includes the correct other-user subinfo' do
        get :show, params: {id: collection.to_param}
        expect(response.body).to include(I18n.t('collections.show.num_of_other_users', count: 1))
      end
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
    let(:post_request) { post :create, params: {collection: collection_params} }

    context 'with valid params' do
      let(:collection_params) { valid_attributes }

      it 'creates a new Collection' do
        expect do
          post_request
        end.to change(Collection, :count).by(1)
      end

      it 'assigns a newly created collection as @collection' do
        post_request
        expect(assigns(:collection)).to be_a(Collection)
      end

      it 'persists @collection' do
        post_request
        expect(assigns(:collection)).to be_persisted
      end

      it 'redirects to the created collection' do
        post_request
        expect(response).to redirect_to(collections_path)
      end

      context 'with task_id' do
        let(:collection_params) { valid_attributes.merge(task_ids: task.id) }
        let(:task) { create(:task) }

        it 'creates a new Collection' do
          expect do
            post_request
          end.to change(Collection, :count).by(1)
        end

        it 'assigns a newly created collection as @collection' do
          post_request
          expect(assigns(:collection)).to be_a(Collection)
        end

        it 'persists @collection' do
          post_request
          expect(assigns(:collection)).to be_persisted
        end

        it 'redirects to the submitted task' do
          post_request
          expect(response).to redirect_to(task_path(task))
        end
      end
    end

    context 'with invalid params' do
      let(:collection_params) { invalid_attributes }

      it 'assigns a newly created but unsaved collection as @collection' do
        post_request
        expect(assigns(:collection)).to be_a_new(Collection)
      end

      it "re-renders the 'new' template" do
        post_request
        expect(response).to render_template('new')
      end

      context 'with task_id' do
        let(:collection_params) { invalid_attributes.merge(task_ids: task.id) }
        let(:task) { create(:task) }

        it 'does not create a new Collection' do
          expect do
            post_request
          end.not_to change(Collection, :count)
        end

        it 'flashes an error' do
          expect { post_request }.to change { flash[:alert] }.to(I18n.t('collections.create.error'))
        end
      end
    end
  end

  describe 'PUT #update' do
    subject(:put_update) { put :update, params: {id: collection.to_param, collection: collection_params} }

    let(:collection) { create(:collection, valid_attributes.merge(users: [user])) }

    context 'with valid params' do
      let(:collection_params) { valid_attributes }
      let(:collection_tasks_attributes) do
        collection.collection_tasks.map do |collection_task|
          collection_task.attributes.symbolize_keys.except(:collection_id, :created_at, :task_id, :updated_at)
        end
      end

      it 'assigns the requested collection as @collection' do
        put_update
        expect(assigns(:collection)).to eq(collection)
      end

      it 'redirects to the collection' do
        put_update
        expect(response).to redirect_to(collections_path)
      end

      context 'with new title' do
        let(:collection_params) { {title: 'new title'} }

        it 'updates the requested collection' do
          expect { put_update }.to change { collection.reload.title }.to('new title')
        end
      end

      context 'with new task order' do
        let(:collection_params) do
          {collection_tasks_attributes: {
            '0': collection_tasks_attributes.first.merge(rank: 0),
            '1': collection_tasks_attributes.second.merge(rank: 1),
          }}
        end

        it 'reorders the tasks in the new order' do
          expect { put_update }.to change { collection.tasks.reload.map(&:id) }.from(collection.task_ids).to(collection.task_ids.reverse)
        end
      end

      context 'when removing a task' do
        let(:collection_params) do
          {collection_tasks_attributes: {
            '0': collection_tasks_attributes.first.merge(rank: 0),
            '1': collection_tasks_attributes.second.merge(_destroy: 1),
          }}
        end

        it 'removes the task' do
          expect { put_update }.to change { collection.tasks.reload.count }.from(2).to(1)
        end
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
    let(:patch_request) { patch :remove_task, params: remove_task_params }
    let(:remove_task_params) { {id: collection.id, task: task.id} }

    it 'removes task from collection' do
      expect { patch_request }.to change(collection.reload.tasks, :count).by(-1)
    end

    context 'when return_to_task is true' do
      let(:remove_task_params) { {id: collection.id, task: task.id, return_to_task: true} }

      it 'removes task from collection' do
        expect { patch_request }.to change(collection.reload.tasks, :count).by(-1)
      end

      it 'redirects to the submitted task' do
        patch_request
        expect(response).to redirect_to(task_path(task))
      end

      context 'with invalid params' do
        let(:remove_task_params) { {id: collection.id, task: create(:task).id} }

        it 'does not remove task from collection' do
          expect { patch_request }.not_to change(collection.reload.tasks, :count)
        end
      end
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
    let(:proforma_version) { '2.1' }
    let(:get_request) { get :download_all, params: {id: collection.id, version: proforma_version} }

    before { allow(ProformaService::ExportTasks).to receive(:call).with(tasks: collection.reload.tasks, options: {version: proforma_version}).and_return(zip) }

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

    context 'when proforma_version is 2.0' do
      let(:proforma_version) { '2.0' }

      it 'sends the correct data' do
        get_request
        expect(response.body).to eql 'dummy'
      end
    end

    context 'when export task raises an error' do
      before { allow(ProformaService::ExportTasks).to receive(:call).with(tasks: collection.reload.tasks, options: {version: proforma_version}).and_raise(ProformaXML::PostGenerateValidationError, '["version not supported"]') }

      it 'redirects to root' do
        get_request
        expect(response).to redirect_to(root_path)
      end

      it 'sets the correct flash message' do
        expect { get_request }.to change { flash[:danger] }.to(I18n.t('proforma_errors.version not supported'))
      end
    end
  end

  describe 'POST #share' do
    let(:collection) { create(:collection, valid_attributes.merge(users:)) }
    let(:users) { [user] }
    let(:post_request) { post :share, params: }
    let(:params) { {id: collection.id, user: recipient.email} }
    let(:recipient) { create(:user) }

    shared_examples 'success' do
      it 'creates a message' do
        expect { post_request }.to change(Message, :count).by(1)
      end

      it 'sends an invitation email' do
        expect { post_request }
          .to have_enqueued_mail(CollectionInvitationMailer, :send_invitation)
          .with(params: {collection:, recipient:}, args: [])
      end

      it 'redirects to collection' do
        post_request
        expect(response).to redirect_to collection
      end

      it 'sets flash message' do
        expect(post_request.request.flash[:notice]).to eql I18n.t('collections.share.success_notice')
      end
    end

    shared_examples 'error' do |expected_flash|
      it 'does not create a message' do
        expect { post_request }.not_to change(Message, :count)
      end

      it 'does not send an invitation email' do
        expect { post_request }
          .not_to have_enqueued_mail(CollectionInvitationMailer, :send_invitation)
          .with(params: {collection:, recipient:}, args: [])
      end

      it 'redirects to collection' do
        post_request
        expect(response).to redirect_to collection
      end

      it 'sets flash message' do
        expect(post_request.request.flash[:alert]).to eql expected_flash
      end
    end

    it_behaves_like 'success'

    context 'when no email is given' do
      let(:params) { {id: collection.id} }

      it_behaves_like 'error', 'Recipient must exist'
    end

    context 'when user already is in collection' do
      let(:users) { [user, recipient] }

      it_behaves_like 'error', "#{Message.human_attribute_name(:recipient_id)} #{I18n.t('activerecord.errors.models.message.user_already_in_collection')}"
    end

    context 'when sending a duplicate invite' do
      before { create(:message, sender: user, recipient:, action: :collection_shared, attachment: collection) }

      it_behaves_like 'error', "#{Message.human_attribute_name(:recipient_id)} #{I18n.t('activerecord.errors.models.message.duplicate_share')}"
    end

    context 'when sending second invite after a first message was deleted by recipient' do
      before { create(:message, sender: user, recipient:, action: :collection_shared, attachment: collection, recipient_status: :deleted) }

      it_behaves_like 'success'
    end
  end

  describe 'POST #view_shared' do
    let(:collection_owner) { create(:user) }
    let(:collection) { create(:collection, valid_attributes.merge(users: [collection_owner])) }
    let(:get_request) { get :view_shared, params: }
    let(:params) { {id: collection.id, user: collection_owner.id} }

    context 'when user has been invited' do
      before { create(:message, sender: collection.users.first, recipient: user, action: :collection_shared, attachment: collection, text: 'Invitation') }

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
      let!(:send_invitation) do
        create(:message, sender: collection.users.first, recipient: user, action: :collection_shared, attachment: collection,
          text: 'Invitation')
      end

      it 'increases usercount of collection' do
        expect { post_request }.to change(collection.reload.users, :count).from(1).to(2)
      end

      it 'deletes the invitation' do
        expect { post_request }.to change(Message, :count).by(-1)
      end

      it 'adds user to collection' do
        post_request
        expect(collection.reload.users).to include user
      end

      it 'redirects to collection' do
        post_request
        expect(response).to redirect_to collection
      end

      context 'when marking the message as deleted fails' do
        let(:search_results) { double }

        before do
          allow(Message).to receive(:received_by).and_return(search_results)
          allow(search_results).to receive_messages(find_by: send_invitation, exists?: true)
          allow(send_invitation).to receive(:mark_as_deleted).and_raise(ActiveRecord::ActiveRecordError)
        end

        it 'does not increase usercount of collection' do
          expect { post_request }.to raise_error(ActiveRecord::ActiveRecordError).and avoid_change(collection.reload.users, :count)
        end

        it 'does not add the user to the collection' do
          expect { post_request }.to raise_error(ActiveRecord::ActiveRecordError)
          expect(collection.reload.users).not_to include user
        end
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

  describe 'POST #toggle_favorite' do
    let!(:collection) { create(:collection, valid_attributes.merge(users:, visibility_level:)) }
    let(:users) { [create(:user), user] }
    let(:visibility_level) { :private }
    let(:post_request) { post :toggle_favorite, params: }
    let(:params) { {id: collection.id} }

    it 'adds collection to users favorites' do
      post_request
      expect(user.favorite_collections).to include collection
    end

    context 'when collection is already a favorite' do
      before { user.favorite_collections << collection }

      it 'removes collection from users favorites' do
        post_request
        expect(user.favorite_collections).not_to include collection
      end
    end

    context 'when user is not in collection' do
      let(:users) { [create(:user)] }

      it 'does not add collection to users favorites' do
        post_request
        expect(user.favorite_collections).not_to include collection
      end

      context 'when collection is public' do
        let(:visibility_level) { :public }

        it 'adds collection to users favorites' do
          post_request
          expect(user.favorite_collections).to include collection
        end
      end
    end
  end

  describe 'POST #push_collection' do
    let!(:collection) { create(:collection, valid_attributes.merge(users:)) }
    let(:users) { [user] }
    let(:post_request) { post :push_collection, params: }
    let(:params) { {id: collection.id, account_link: account_link.id} }
    let(:account_link) { create(:account_link, user: account_link_user) }
    let(:account_link_user) { user }
    let(:push_task_return) { [] }

    before { allow(controller).to receive(:push_tasks).and_return(push_task_return) }

    shared_examples 'redirects to collection and flashes message successfully' do
      it 'redirects to collection' do
        post_request
        expect(response).to redirect_to(collection_path(collection))
      end

      it 'shows success flash message' do
        post_request
        expect(flash[:notice]).to eq I18n.t('collections.push_collection.push_external_notice', account_link: account_link.name)
      end
    end

    shared_examples 'redirect to collection-list and flashes not authorized' do
      it 'redirects to collection list' do
        post_request
        expect(response).to redirect_to(collections_url)
      end

      it 'shows flash message' do
        post_request
        expect(flash[:alert]).to eq I18n.t('common.errors.not_authorized')
      end
    end

    it_behaves_like 'redirects to collection and flashes message successfully'

    context 'when push_tasks returns errors' do
      let(:push_task_return) { ['error'] }

      it 'redirects to collection' do
        post_request
        expect(response).to redirect_to(collection_path(collection))
      end

      it 'shows success flash message' do
        post_request
        expect(flash[:alert]).to eq I18n.t('collections.push_collection.not_working', account_link: account_link.name)
      end
    end

    context 'when user is not in collection' do
      let(:users) { [create(:user)] }

      it_behaves_like 'redirect to collection-list and flashes not authorized'
    end

    context 'when the account link is shared with the requesting user' do
      let(:account_link) { create(:account_link, user: create(:user), shared_users: Array.wrap(user)) }

      it_behaves_like 'redirects to collection and flashes message successfully'
    end

    context 'when the account link is neither owned by nor shared with the requesting user' do
      let(:account_link_user) { create(:user) }

      it_behaves_like 'redirect to collection-list and flashes not authorized'
    end
  end
  # get collections_all # adminview
end
