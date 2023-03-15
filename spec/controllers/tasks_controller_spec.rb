# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TasksController do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, users: [user], tasks: []) }
  let(:valid_attributes) { {user:} }

  let(:invalid_attributes) { {title: ''} }

  before { sign_in user }

  describe 'GET #index' do
    subject(:get_request) { get :index, params: }

    let(:get_request_without_params) { get :index, params: {} }
    let!(:task) { create(:task, valid_attributes) }
    let(:params) { {} }

    it 'shows the task' do
      get_request
      expect(assigns(:tasks)).to contain_exactly task
    end

    context 'with a task of a different user' do
      let!(:other_task) { create(:task, user: build(:user)) }

      context 'when visibility is owner' do
        let(:params) { {visibility: 'owner'} }

        it 'shows all Tasks of that user' do
          get_request
          expect(assigns(:tasks)).to contain_exactly task
        end
      end

      context 'when visibility is public' do
        let(:params) { {visibility: 'public'} }

        it 'shows all Tasks not owned by user' do
          get_request
          expect(assigns(:tasks)).to contain_exactly other_task
        end
      end
    end

    context 'when user has multiple tasks' do
      before { create(:task, valid_attributes) }

      it 'shows all Tasks of that user' do
        get_request
        expect(assigns(:tasks).size).to eq 2
      end

      context 'when a filter is used' do
        let(:params) { {search: ransack_params} }
        let(:ransack_params) { {'title_or_description_cont' => 'filter'} }
        let!(:task) { create(:task, user:, title: 'filter me') }

        it 'shows the matching Task' do
          get_request
          expect(assigns(:tasks)).to contain_exactly task
        end

        context 'when a second request without searchparams is made' do
          it 'shows the matching Task' do
            get_request
            get_request_without_params
            expect(assigns(:tasks)).to contain_exactly task
          end
        end
      end
    end
  end

  describe 'GET #show' do
    subject(:get_request) { get :show, params: {id: task.to_param} }

    let!(:task) { create(:task, valid_attributes) }

    it 'assigns the requested task to instance variable' do
      get_request
      expect(assigns(:task)).to eq(task)
    end

    context 'when task has an tasks_file' do
      let!(:file) { create(:task_file, fileable: task) }

      it "assigns task's files to instance variable" do
        get_request
        expect(assigns(:files)).to include(file)
      end
    end

    context 'when task has a test' do
      let!(:test) { create(:test, task:) }

      it "assigns task's tests to instance variable" do
        get_request
        expect(assigns(:tests)).to include(test)
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new task as @task' do
      get :new, params: {}
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe 'GET #edit' do
    let!(:task) { create(:task, valid_attributes) }

    it 'assigns the requested task as @task' do
      get :edit, params: {id: task.to_param}
      expect(assigns(:task)).to eq(task)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      subject(:post_request) { post :create, params: {task: valid_params} }

      let(:valid_params) do
        {
          title: 'title',
          descriptions_attributes: {'0' => {text: 'description', primary: true}},
          programming_language_id: create(:programming_language, :ruby).id,
          license_id: create(:license),
          language: 'de',
        }
      end

      it 'creates a new Task' do
        expect { post_request }.to change(Task, :count).by(1)
      end

      it 'assigns a newly created task as @task' do
        post_request
        expect(assigns(:task)).to be_persisted
      end

      it 'redirects to the created task' do
        post_request
        expect(response).to redirect_to(Task.last)
      end

      context 'with group_tasks_params' do
        subject(:post_request) { post :create, params: {task: valid_params, group_tasks: group_tasks_params} }

        let(:group_tasks_params) { {group_ids: ['', group.id.to_s]} }
        let(:group) { create(:group, group_memberships: build_list(:group_membership, 1, :with_admin, user:)) }

        it 'creates a new Task' do
          expect { post_request }.to change(Task, :count).by(1)
        end

        it 'adds the group to the task' do
          post_request
          expect(Task.last.groups).to match_array(group)
        end

        it 'assigns a newly created task as @task' do
          post_request
          expect(assigns(:task)).to be_persisted
        end

        it 'redirects to the created task' do
          post_request
          expect(response).to redirect_to(Task.last)
        end

        context 'when no groups are given' do
          let(:group_tasks_params) { {group_ids: []} }

          it 'adds no groups to the Task' do
            post_request
            expect(Task.last.groups).to be_empty
          end
        end

        context 'when two groups are given' do
          let(:group_tasks_params) { {group_ids: [group.id.to_s, group2.id.to_s]} }
          let(:group2) { create(:group, group_memberships: build_list(:group_membership, 1, :with_admin, user:)) }

          it 'adds two groups to the Task' do
            post_request
            expect(Task.last.groups).to match_array([group, group2])
          end
        end

        context 'with two groups, but user does not have admin role in one of the groups' do
          let(:group_tasks_params) { {group_ids: [group.id.to_s, group2.id.to_s]} }

          let(:group2) { create(:group, group_memberships: [build(:group_membership, user:), build(:group_membership, :with_admin)]) }

          it 'only adds one group to the Task' do
            post_request
            expect(Task.last.groups).to match_array([group])
          end
        end
      end
    end

    context 'with invalid params' do
      subject(:post_request) { post :create, params: {task: invalid_attributes} }

      it 'assigns a newly created but unsaved task as @task' do
        post_request
        expect(assigns(:task)).to be_a_new(Task)
      end

      it "re-renders the 'new' template" do
        post_request
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    subject(:put_update) { put :update, params: {id: task.to_param, task: changed_attributes} }

    let(:changed_attributes) { {title: 'new_title'} }
    let!(:task) { create(:task, valid_attributes) }
    let(:valid_attributes) { {user:, title: 'title'} }

    context 'with valid params' do
      it 'updates the requested task' do
        expect { put_update }.to change { task.reload.title }.to('new_title')
      end

      it 'assigns the requested task as @task' do
        put_update
        expect(assigns(:task)).to eq(task)
      end

      it 'redirects to the task' do
        put_update
        expect(response).to redirect_to(task)
      end

      context 'when task has a test' do
        subject(:put_update) do
          put :update, params: {id: task.to_param, task: changed_attributes.merge({'tests_attributes' => tests_attributes})}
        end

        let(:test) { build(:test) }
        let!(:task) { create(:task, valid_attributes.merge(tests: [test])) }

        let(:tests_attributes) { {'0' => test.attributes.merge('title' => 'new_test_title')} }

        it 'updates the requested task' do
          expect { put_update }.to change { task.reload.title }.to('new_title')
        end

        it 'updates the test' do
          expect { put_update }.to change { task.tests.first.reload.title }.to('new_test_title')
        end
      end

      context 'with group_tasks_params' do
        subject(:put_update) { put :update, params: {id: task.to_param, task: valid_attributes, group_tasks: group_tasks_params} }

        let(:group_tasks_params) { {group_ids: ['', group.id.to_s]} }
        let(:group) { create(:group, group_memberships: build_list(:group_membership, 1, :with_admin, user:)) }

        it 'adds the group to the task' do
          put_update
          expect(task.reload.groups).to match_array(group)
        end

        context 'when no groups are given' do
          let(:group_tasks_params) { {group_ids: []} }

          it 'adds no groups to the Task' do
            put_update
            expect(task.reload.groups).to be_empty
          end
        end

        context 'when two groups are given' do
          let(:group_tasks_params) { {group_ids: [group.id.to_s, group2.id.to_s]} }
          let(:group2) { create(:group, group_memberships: build_list(:group_membership, 1, :with_admin, user:)) }

          it 'adds two groups to the Task' do
            put_update
            expect(task.reload.groups).to match_array([group, group2])
          end
        end

        context 'with two groups, but user does not have admin role in one of the groups' do
          let(:group_tasks_params) { {group_ids: [group.id.to_s, group2.id.to_s]} }

          let(:group2) { create(:group, group_memberships: [build(:group_membership, user:), build(:group_membership, :with_admin)]) }

          it 'adds group to the Task' do
            put_update
            expect(task.reload.groups).to match_array([group])
          end
        end

        context 'when task has a group and it is not supplied in the params' do
          before { task.groups << group }

          let(:group_tasks_params) { {group_ids: ['']} }

          it 'removes the group from the Task' do
            expect { put_update }.to change { task.reload.groups }.from(contain_exactly(group)).to(be_empty)
          end
        end

        context 'when task has a group and it is supplied in the params' do
          before { task.groups << group }

          let(:group_tasks_params) { {group_ids: [group.id.to_s]} }

          it 'does not remove the group from the Task' do
            expect { put_update }.not_to(change { task.reload.groups.map(&:id) })
          end
        end
      end
    end

    context 'with invalid params' do
      subject(:put_update) { put :update, params: {id: task.to_param, task: invalid_attributes} }

      it 'assigns the task as @task' do
        put_update
        expect(assigns(:task)).to eq(task)
      end

      it "re-renders the 'edit' template" do
        put_update
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    subject(:delete_request) do
      delete :destroy, params: {id: task.to_param}
    end

    let!(:task) { create(:task, valid_attributes) }

    it 'destroys the requested task' do
      expect { delete_request }.to change(Task, :count).by(-1)
    end

    it 'redirects to the tasks list' do
      delete_request
      expect(response).to redirect_to(tasks_url)
    end
  end

  describe 'GET #download' do
    subject(:get_request) { get :download, params: {id: task.id} }

    let(:task) { create(:task, valid_attributes) }
    let(:zip) { instance_double(StringIO, string: 'dummy') }

    before { allow(ProformaService::ExportTask).to receive(:call).with(task:).and_return(zip) }

    it 'calls the ExportTask service' do
      get_request
      expect(ProformaService::ExportTask).to have_received(:call)
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
      expect(response.header['Content-Disposition']).to include "attachment; filename=\"task_#{task.id}.zip\""
    end
  end

  describe 'POST #import_start' do
    render_views

    subject(:post_request) { post :import_start, params: {zip_file:}, format: :js, xhr: true }

    let(:zip_file) { fixture_file_upload('proforma_import/testfile.zip', 'application/zip') }

    before { allow(ProformaService::CacheImportFile).to receive(:call).and_call_original }

    it 'renders correct views' do
      post_request
      expect(response).to render_template('import_start', 'import_dialog_content')
    end

    it 'creates an ImportFileCache' do
      expect { post_request }.to change(ImportFileCache, :count).by(1)
    end

    it 'calls service' do
      post_request
      expect(ProformaService::CacheImportFile).to have_received(:call).with(user:,
        zip_file: be_a(ActionDispatch::Http::UploadedFile))
    end

    it 'renders import view for one task' do
      post_request
      expect(response.body.scan('data-import-id').count).to be 1
    end

    context 'when file contains three tasks' do
      let(:zip_file) { fixture_file_upload('proforma_import/testfile_multi.zip', 'application/zip') }

      it 'renders import view for three tasks' do
        post_request
        expect(response.body.scan('data-import-id').count).to be 3
      end
    end

    context 'when zip_file is submitted' do
      let(:zip_file) {}

      it 'renders correct json' do
        post_request
        expect(JSON.parse(response.body, symbolize_names: true)).to eql({status: 'failure', message: 'You need to choose a file.'})
      end
    end

    context "when zip_file is 'undefined'" do
      let(:zip_file) { 'undefined' }

      it 'renders correct json' do
        post_request
        expect(JSON.parse(response.body, symbolize_names: true)).to eql({status: 'failure', message: 'You need to choose a file.'})
      end
    end
  end

  describe 'POST #import_confirm' do
    render_views

    subject(:post_request) do
      post :import_confirm,
        params: {import_id: import_data[1][:import_id], subfile_id: import_data[0], import_type: 'export'}, xhr: true
    end

    let(:zip_file) { fixture_file_upload('proforma_import/testfile_multi.zip', 'application/zip') }
    let(:data) { ProformaService::CacheImportFile.call(user:, zip_file:) }
    let(:import_data) { data.first }

    it 'creates the task' do
      expect { post_request }.to change(Task, :count).by(1)
    end

    it 'renders correct json' do
      post_request
      expect(response.body).to include('successfully imported').and(include('Show task').and(include('Hide')))
    end

    context 'when import raises a validation error' do
      before { allow(ProformaService::ImportTask).to receive(:call).and_raise(ActiveRecord::RecordInvalid) }

      it 'renders correct json' do
        post_request
        expect(response.body).to include('failed').and(include('Record invalid').and(include('"actions":""')))
      end
    end
  end

  describe 'POST #import_uuid_check' do
    subject(:post_request) { post :import_uuid_check, params: {uuid:} }

    let!(:task) { create(:task, valid_attributes) }
    let(:headers) { {'Authorization' => "Bearer #{account_link.api_key}"} }
    let(:account_link) { create(:account_link, user:) }
    let(:uuid) { task.reload.uuid }

    before { request.headers.merge! headers }

    it 'renders correct response' do
      post_request
      expect(response).to have_http_status(:success)

      expect(JSON.parse(response.body).symbolize_keys).to eql(uuid_found: true, update_right: true)
    end

    context 'when api_key is incorrect' do
      let(:headers) { {'Authorization' => 'Bearer XXXXXX'} }

      it 'renders correct response' do
        post_request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is cannot update the task' do
      let(:account_link) { create(:account_link, api_key: 'anotherkey') }

      it 'renders correct response' do
        post_request
        expect(response).to have_http_status(:success)

        expect(JSON.parse(response.body).symbolize_keys).to eql(uuid_found: true, update_right: false)
      end
    end

    context 'when the searched task does not exist' do
      let(:uuid) { 'anotheruuid' }

      it 'renders correct response' do
        post_request
        expect(response).to have_http_status(:success)

        expect(JSON.parse(response.body).symbolize_keys).to eql(uuid_found: false)
      end
    end
  end

  describe 'POST #import_external' do
    subject(:post_request) { post :import_external, body: zip_file_content }

    let(:account_link) { create(:account_link, user:) }
    let(:zip_file_content) { 'zipped task xml' }
    let(:headers) { {'Authorization' => "Bearer #{account_link.api_key}"} }

    before do
      request.headers.merge! headers
      allow(ProformaService::Import).to receive(:call)
    end

    it 'responds with correct status code' do
      post_request
      expect(response).to have_http_status(:created)
    end

    it 'calls service' do
      post_request
      expect(ProformaService::Import).to have_received(:call).with(zip: be_a(Tempfile).and(has_content(zip_file_content)), user:)
    end

    context 'when import fails with ProformaError' do
      before { allow(ProformaService::Import).to receive(:call).and_raise(Proforma::PreImportValidationError) }

      it 'responds with correct status code' do
        post_request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when import fails due to another error' do
      before { allow(ProformaService::Import).to receive(:call).and_raise(StandardError) }

      it 'responds with correct status code' do
        post_request
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  describe 'POST #export_external_start' do
    let(:task) { create(:task, valid_attributes) }
    let(:account_link) { create(:account_link, user: account_link_user) }
    let(:account_link_user) { user }
    let(:get_request) do
      get :export_external_start, params: {id: task.id, account_link: account_link.id}, format: :js, xhr: true
    end

    it 'renders export_external_start javascript' do
      get_request
      expect(response).to render_template('export_external_start')
    end
  end

  describe 'POST #export_external_check' do
    render_views

    let!(:task) { create(:task, valid_attributes).reload }
    let(:account_link) { create(:account_link, user: account_link_user) }
    let(:account_link_user) { user }
    let(:post_request) do
      post :export_external_check, params: {id: task.id, account_link: account_link.id}, format: :json, xhr: true
    end
    let(:external_check_hash) { {message:, uuid_found:, update_right: true, error:} }
    let(:message) { 'message' }
    let(:uuid_found) { true }
    let(:error) { nil }

    before do
      allow(TaskService::CheckExternal).to receive(:call).with(uuid: task.uuid,
        account_link:).and_return(external_check_hash)
    end

    it 'renders the correct contents as json' do
      post_request
      expect(JSON.parse(response.body).symbolize_keys[:message]).to eq('message')
      expect(JSON.parse(response.body).symbolize_keys[:actions]).to(
        include('button').and(include('Abort').and(include('Overwrite')).and(include('Create new')))
      )
      expect(JSON.parse(response.body).symbolize_keys[:actions]).to(
        not_include('Retry').and(not_include('Hide'))
      )
    end

    context 'when there is an error' do
      let(:error) { 'error' }

      it 'renders the correct contents as json' do
        post_request
        expect(JSON.parse(response.body).symbolize_keys[:message]).to eq('message')
        expect(JSON.parse(response.body).symbolize_keys[:actions]).to(
          include('button').and(include('Abort')).and(include('Retry'))
        )
        expect(JSON.parse(response.body).symbolize_keys[:actions]).to(
          not_include('Overwrite').and(not_include('Create new')).and(not_include('Export')).and(not_include('Hide'))
        )
      end
    end

    context 'when uuid_found is false' do
      let(:uuid_found) { false }

      it 'renders the correct contents as json' do
        post_request
        expect(JSON.parse(response.body).symbolize_keys[:message]).to eq('message')
        expect(JSON.parse(response.body).symbolize_keys[:actions]).to(
          include('button').and(include('Abort')).and(include('Export'))
        )
        expect(JSON.parse(response.body).symbolize_keys[:actions]).to(
          not_include('Overwrite').and(not_include('Create new')).and(not_include('Hide'))
        )
      end
    end
  end

  describe 'POST #export_external_confirm' do
    render_views

    let!(:task) { create(:task, valid_attributes) }
    let(:account_link) { create(:account_link, user: account_link_user) }
    let(:account_link_user) { user }
    let(:post_request) do
      post :export_external_confirm, params: {push_type:, id: task.id, account_link: account_link.id}, format: :json,
        xhr: true
    end
    let(:push_type) { 'export' }
    let(:error) {}

    before do
      allow(ProformaService::ExportTask).to receive(:call)
        .with(task: an_instance_of(Task), options: {description_format: 'md'})
        .and_return('zip stream')
      allow(TaskService::PushExternal).to receive(:call)
        .with(zip: 'zip stream', account_link:)
        .and_return(error)
    end

    it 'does not create a new task' do
      expect { post_request }.not_to change(Task, :count)
    end

    it 'renders correct response' do
      post_request

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).symbolize_keys[:message]).to(include('successfully exported'))
      expect(JSON.parse(response.body).symbolize_keys[:status]).to(eql('success'))
      expect(JSON.parse(response.body).symbolize_keys[:actions]).to(include('button').and(include('Hide')))
      expect(JSON.parse(response.body).symbolize_keys[:actions]).to(not_include('Retry').and(not_include('Abort')))
    end

    context 'when push_type is create_new' do
      let(:push_type) { 'create_new' }
      let(:return_task) { Task.last }

      it 'creates a new task' do
        expect { post_request }.to change(Task, :count).by(1)
      end

      context 'when an error occurs' do
        let(:error) { 'exampleerror' }

        it 'deletes the new task' do
          expect { post_request }.not_to change(Task, :count)
        end
      end
    end

    context 'when an error occurs' do
      let(:error) { 'exampleerror' }

      it 'renders correct response' do
        post_request
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).symbolize_keys[:message]).to(include('failed').and(include('exampleerror')))
        expect(JSON.parse(response.body).symbolize_keys[:status]).to(eql('fail'))
        expect(JSON.parse(response.body).symbolize_keys[:actions]).to(include('button').and(include('Retry')).and(include('Abort')))
        expect(JSON.parse(response.body).symbolize_keys[:actions]).to(not_include('Hide'))
      end
    end

    context 'without push_type' do
      let(:push_type) {}

      it 'responds with status 500' do
        post_request
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
