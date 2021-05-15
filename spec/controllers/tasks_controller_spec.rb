# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, users: [user], tasks: []) }
  let(:valid_attributes) { {user: user} }

  let(:invalid_attributes) { {title: ''} }

  let(:valid_session) { {user_id: user.id} }

  describe 'GET #index' do
    subject(:get_request) { get :index, params: params, session: valid_session }

    let(:get_request_without_params) { get :index, params: {}, session: valid_session }
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
        let!(:task) { create(:task, user: user, title: 'filter me') }

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
    let!(:task) { create(:task, valid_attributes) }
    let(:get_request) { get :show, params: {id: task.to_param}, session: valid_session }

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
      let!(:test) { create(:test, task: task) }

      it "assigns task's tests to instance variable" do
        get_request
        expect(assigns(:tests)).to include(test)
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new task as @task' do
      get :new, params: {}, session: valid_session
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe 'GET #edit' do
    let!(:task) { create(:task, valid_attributes) }

    it 'assigns the requested task as @task' do
      get :edit, params: {id: task.to_param}, session: valid_session
      expect(assigns(:task)).to eq(task)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          title: 'title',
          descriptions_attributes: {'0' => {text: 'description', primary: true}},
          programming_language_id: create(:programming_language, :ruby).id,
          license_id: create(:license)
        }
      end

      it 'creates a new Task' do
        expect do
          post :create, params: {task: valid_params}, session: valid_session
        end.to change(Task, :count).by(1)
      end

      it 'assigns a newly created task as @task' do
        post :create, params: {task: valid_params}, session: valid_session
        expect(assigns(:task)).to be_persisted
      end

      it 'redirects to the created task' do
        post :create, params: {task: valid_params}, session: valid_session
        expect(response).to redirect_to(Task.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved task as @task' do
        post :create, params: {task: invalid_attributes}, session: valid_session
        expect(assigns(:task)).to be_a_new(Task)
      end

      it "re-renders the 'new' template" do
        post :create, params: {task: invalid_attributes}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    let(:update_attributes) { {title: 'new_title'} }
    let!(:task) { create(:task, valid_attributes) }
    let(:valid_attributes) { {user: user, title: 'title'} }
    let(:put_update) { put :update, params: {id: task.to_param, task: update_attributes}, session: valid_session }

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
        let(:test) { build(:test) }
        let!(:task) { create(:task, valid_attributes.merge(tests: [test])) }

        let(:tests_attributes) { {'0' => test.attributes.merge('title' => 'new_test_title')} }

        let(:put_update) do
          put :update, params: {id: task.to_param, task: update_attributes.merge({'tests_attributes' => tests_attributes})},
                       session: valid_session
        end

        it 'updates the requested task' do
          expect { put_update }.to change { task.reload.title }.to('new_title')
        end

        it 'updates the test' do
          expect { put_update }.to change { task.tests.first.reload.title }.to('new_test_title')
        end
      end
    end

    context 'with invalid params' do
      it 'assigns the task as @task' do
        put :update, params: {id: task.to_param, task: invalid_attributes}, session: valid_session
        expect(assigns(:task)).to eq(task)
      end

      it "re-renders the 'edit' template" do
        put :update, params: {id: task.to_param, task: invalid_attributes}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:task) { create(:task, valid_attributes) }

    it 'destroys the requested task' do
      expect do
        delete :destroy, params: {id: task.to_param}, session: valid_session
      end.to change(Task, :count).by(-1)
    end

    it 'redirects to the tasks list' do
      delete :destroy, params: {id: task.to_param}, session: valid_session
      expect(response).to redirect_to(tasks_url)
    end
  end

  describe 'POST #download' do
    let(:task) { create(:task, valid_attributes) }

    let(:get_request) { get :download, params: {id: task.id}, session: valid_session }
    let(:zip) { instance_double('StringIO', string: 'dummy') }

    before { allow(ProformaService::ExportTask).to receive(:call).with(task: task).and_return(zip) }

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

  describe 'GET #import_start' do
    render_views

    let(:post_request) { post :import_start, params: {zip_file: zip_file}, session: valid_session, format: :js, xhr: true }
    let(:zip_file) { fixture_file_upload('files/proforma_import/testfile.zip', 'application/zip') }

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
      expect(ProformaService::CacheImportFile).to have_received(:call).with(user: user,
                                                                            zip_file: be_a(ActionDispatch::Http::UploadedFile))
    end

    it 'renders import view for one task' do
      post_request
      expect(response.body.scan('data-import-id').count).to be 1
    end

    context 'when file contains three tasks' do
      let(:zip_file) { fixture_file_upload('files/proforma_import/testfile_multi.zip', 'application/zip') }

      it 'renders import view for three tasks' do
        post_request
        expect(response.body.scan('data-import-id').count).to be 3
      end
    end

    context 'when no file is submitted' do
      let(:zip_file) {}

      it 'raises error' do
        expect { post_request }.to raise_error('You need to choose a file.')
      end
    end
  end

  describe 'POST #import_confirm' do
    render_views

    let(:zip_file) { fixture_file_upload('files/proforma_import/testfile_multi.zip', 'application/zip') }
    let(:data) { ProformaService::CacheImportFile.call(user: user, zip_file: zip_file) }
    let(:import_data) { data.first }
    let(:post_request) do
      post :import_confirm,
           params: {import_id: import_data[1][:import_id], subfile_id: import_data[0], import_type: 'export'},
           session: valid_session, xhr: true
    end

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
end
