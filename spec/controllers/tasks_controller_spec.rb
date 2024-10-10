# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TasksController do
  render_views

  let(:user) { create(:user) }
  let(:collection) { create(:collection, users: [user], tasks: []) }
  let(:valid_attributes) { {user:, access_level:} }
  let(:access_level) { :private }

  let(:invalid_attributes) { {title: ''} }

  describe 'GET #index' do
    subject(:get_request) { get :index, params: }

    before { sign_in user }

    let(:get_request_without_params) { get :index, params: {} }
    let!(:task) { create(:task, valid_attributes) }
    let(:params) { {} }

    it 'shows the task' do
      get_request
      expect(assigns(:tasks)).to contain_exactly task
    end

    context 'with a task of a different user' do
      let!(:other_task) { create(:task, user: build(:user), access_level: :public) }

      context 'when visibility is owner' do
        let(:params) { {visibility: :owner} }

        it 'shows all Tasks of that user' do
          get_request
          expect(assigns(:tasks)).to contain_exactly task
        end
      end

      context 'when visibility is public' do
        let(:params) { {visibility: :public} }

        it 'shows all Tasks with a visibility of public' do
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
    end

    context 'when a filter is used' do
      before { create(:task, user:, title: 'filter me out key1', description: 'key1 key2', labels: [labels[0]], programming_language: python_lang) }

      let(:labels) { [create(:label, name: 'l1'), create(:label, name: 'l2'), create(:label, name: 'l3')] }
      let(:python_lang) { create(:programming_language, :python) }
      let(:ruby_lang) { create(:programming_language, :ruby) }

      let!(:task1) { create(:task, user:, title: 'find me key3 (key1)', description: 'key2 key4', labels:, programming_language: ruby_lang) }

      let(:params) { {q: ransack_params} }

      shared_examples 'shows task1' do
        it 'shows only the matching task' do
          get_request
          expect(assigns(:tasks)).to contain_exactly task1
        end
      end

      context 'when a fulltext search filter is used' do
        requests = {
          'title only' => 'key1 key3',
          'description only' => 'key2 key4',
          'labels only' => 'l1 l2',
          'programming language only' => 'ruby',
          'title and description' => 'key1 key4',
          'title, description and labels' => 'l1 key4 key1',
          'labels and programming language' => 'l1 ruby',
        }

        requests.each do |description, keywords|
          context "when using filter keywords from #{description}" do
            let(:ransack_params) { {'fulltext_search' => keywords} }

            include_examples 'shows task1'
          end
        end
      end

      context 'when a label filter is used' do
        let(:ransack_params) { {'has_all_labels' => %w[l1 l3]} }

        include_examples 'shows task1'
      end

      context 'when a fulltext search filter and label filter are combined' do
        let(:ransack_params) { {'fulltext_search' => 'key1 key2', 'has_all_labels' => %w[l3]} }

        include_examples 'shows task1'
      end

      context 'when a programming language filter is used' do
        let(:ransack_params) { {'programming_language_id_in' => ruby_lang.id} }

        include_examples 'shows task1'
      end

      context 'when a second request without searchparams is made' do
        let(:ransack_params) { {'fulltext_search' => 'key1 key2 l3 l1'} }

        it 'shows only the matching task' do
          get_request
          get_request_without_params
          expect(assigns(:tasks)).to contain_exactly task1
        end
      end
    end

    context 'when no user is signed in' do
      before { sign_out user }

      it 'redirects to sign-in page' do
        get_request
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'shows a flash message' do
        get_request
        expect(flash[:alert]).to eq I18n.t('common.errors.not_signed_in')
      end
    end
  end

  describe 'GET #show' do
    subject(:get_request) { get :show, params: {id: task.to_param} }

    let!(:task) { create(:task, valid_attributes) }

    context 'when not signed in' do
      it 'redirects to sign in page' do
        expect(get_request).to redirect_to(new_user_session_path)
      end

      context 'when task is public' do
        let(:access_level) { :public }
        let(:groups) { create_list(:group, 2) }
        let(:collections) { create_list(:collection, 2) }
        let(:ratings) { create_list(:rating, 2) }
        let(:comments) { create_list(:comment, 2) }
        let(:task) { create(:task, valid_attributes.merge(groups:, collections:, ratings:, comments:)) }

        it 'renders the show view successfully' do
          expect(get_request).to render_template(:show)
          expect(response).to have_http_status :ok
        end
      end
    end

    context 'when signed in' do
      before { sign_in user }

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

        context 'when test has a framework' do
          let(:testing_framework) { create(:testing_framework) }
          let(:test) { create(:test, task:, testing_framework:) }

          it "includes the frameworks's name and version in response" do
            get_request
            expect(response.body).to include(testing_framework.name_with_version)
          end
        end
      end

      context 'when description contains quotes' do
        # the quotes should render as normal quotes instead of ldquo and rdquo (see app/helpers/application_helper.rb:53)
        let(:task) { create(:task, valid_attributes.merge(description:)) }
        let(:description) { 'foo "bar" bla' }

        it 'renders the quotes correctly' do
          get_request
          expect(response.body).to include(description)
        end
      end

      context 'when task is a contribution' do
        let!(:contribution) { create(:task_contribution, suggestion: task) }

        it 'redirects the user to the contribution' do
          get_request
          expect(response).to redirect_to([contribution.base, contribution])
        end
      end
    end
  end

  describe 'GET #new' do
    before { sign_in user }

    it 'assigns a new task as @task' do
      get :new, params: {}
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe 'GET #edit' do
    before { sign_in user }

    let!(:task) { create(:task, valid_attributes) }

    it 'assigns the requested task as @task' do
      get :edit, params: {id: task.to_param}
      expect(assigns(:task)).to eq(task)
    end

    context 'when task is a contribution' do
      let!(:contribution) { create(:task_contribution, suggestion: task) }

      it 'redirects the user to the contribution' do
        get :edit, params: {id: task.to_param}
        expect(response).to redirect_to(action: 'edit', controller: 'task_contributions', id: contribution.id, task_id: contribution.base.id)
      end
    end
  end

  describe 'POST #create' do
    before { sign_in user }

    context 'with valid params' do
      subject(:post_request) { post :create, params: {task: valid_params, group_tasks: {group_ids: ['']}} }

      let(:valid_params) do
        {
          title: 'title',
          descriptions_attributes: {'0' => {text: 'description', primary: true}},
          programming_language_id: create(:programming_language, :ruby).id,
          license_id: create(:license),
          language: 'de',
          label_names: create_list(:label, 1).map(&:name),
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

      it 'sets license correctly' do
        post_request
        expect(assigns(:task).license).to match(valid_params[:license_id])
      end

      it 'sets labels correctly' do
        post_request
        expect(assigns(:task).labels.map(&:name)).to match_array(valid_params[:label_names])
      end

      it 'creates a new TaskLabel' do
        expect { post_request }.to change(TaskLabel, :count).by(1)
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
          let(:group_tasks_params) { {group_ids: ['']} }

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
            expect(Task.last.groups).to contain_exactly(group, group2)
          end
        end

        context 'with two groups, but user does not have admin role in one of the groups' do
          let(:group_tasks_params) { {group_ids: [group.id.to_s, group2.id.to_s]} }

          let(:group2) { create(:group, group_memberships: [build(:group_membership, user:), build(:group_membership, :with_admin)]) }

          it 'only adds one group to the Task' do
            post_request
            expect(Task.last.groups).to contain_exactly(group)
          end
        end
      end
    end

    context 'with invalid params' do
      subject(:post_request) { post :create, params: {task: invalid_attributes, group_tasks: {group_ids: ['']}} }

      it 'assigns a newly created but unsaved task as @task' do
        post_request
        expect(assigns(:task)).to be_a_new(Task)
      end

      it "re-renders the 'new' template" do
        post_request
        expect(response).to render_template('new')
      end

      context 'when new label needs to be created' do
        let(:invalid_attributes) { {title: '', label_names: [not_existing_label_name]} }
        let(:not_existing_label_name) { 'some new label' }

        it "re-renders the 'new' template successfully" do
          post_request
          expect(response).to have_http_status(:success)
          expect(response).to render_template('new')
        end
      end
    end
  end

  describe 'PUT #update' do
    subject(:put_update) { put :update, params: {id: task.to_param, task: changed_attributes, group_tasks: {group_ids: ['']}} }

    before { sign_in user }

    let(:existing_label) { create(:label) }
    let(:new_label) { create(:label) }

    let!(:task) { create(:task, valid_attributes) }
    let(:valid_attributes) do
      {
        user:,
        title: 'title',
        license: create(:license, name: 'old_license'),
        labels: [existing_label],
      }
    end
    let(:changed_attributes) do
      {
        title: 'new_title',
        license_id: create(:license, name: 'new_license').id,
        label_names: [new_label.name],
      }
    end

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

      it 'updates the license' do
        expect { put_update }.to change { task.reload.license.name }.to('new_license')
      end

      it 'updates the tasks labels' do
        expect { put_update }.to change { task.reload.labels }.from([existing_label]).to([new_label])
      end

      it 'does not create a new label' do
        create(:task, title: 'An existing task with the new label', labels: [new_label])
        old_labels = Label.all.to_a
        put_update
        expect(Label.all.to_a.difference(old_labels)).to be_empty
      end

      it 'deletes unused labels' do
        put_update
        expect(Label.all).to not_include(existing_label)
      end

      it 'does not delete any used label' do
        create(:task, title: 'An existing task with the existing label', labels: [existing_label])
        put_update
        expect(Label.all).to include(existing_label)
      end

      context 'when requesting a new label to be created' do
        let(:changed_attributes) { {label_names: [not_existing_label_name]} }
        let(:not_existing_label_name) { 'some new label' }

        it 'creates new task label' do
          put_update
          expect(Label.where(name: not_existing_label_name)).not_to be_empty
        end

        it 'creates a label with the correct name' do
          put_update
          expect(Label.where(name: not_existing_label_name).size).to be 1
        end

        it 'sets newly created task label' do
          expect { put_update }.to change { task.reload.labels.map(&:name) }.from([existing_label.name]).to([not_existing_label_name])
        end
      end

      context 'when task has a test' do
        subject(:put_update) do
          put :update, params: {id: task.to_param, task: changed_attributes.merge(tests_attributes:), group_tasks: {group_ids: ['']}}
        end

        let(:test) { build(:test) }
        let(:new_testing_framework) { create(:testing_framework) }
        let!(:task) { create(:task, valid_attributes.merge(tests: [test])) }

        let(:tests_attributes) { {'0': test.attributes.symbolize_keys.merge(title: 'new_test_title', testing_framework_id: new_testing_framework.id)} }

        it 'updates the requested task' do
          expect { put_update }.to change { task.reload.title }.to('new_title')
        end

        it "updates the test's title" do
          expect { put_update }.to change { task.tests.first.reload.title }.to('new_test_title')
        end

        it "updates the test's framework" do
          expect { put_update }.to change { task.tests.first.reload.testing_framework }.to(new_testing_framework)
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
          let(:group_tasks_params) { {group_ids: ['']} }

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
            expect(task.reload.groups).to contain_exactly(group, group2)
          end
        end

        context 'with two groups, but user does not have admin role in one of the groups' do
          let(:group_tasks_params) { {group_ids: [group.id.to_s, group2.id.to_s]} }

          let(:group2) { create(:group, group_memberships: [build(:group_membership, user:), build(:group_membership, :with_admin)]) }

          it 'adds group to the Task' do
            put_update
            expect(task.reload.groups).to contain_exactly(group)
          end
        end

        context 'when task has a group and it is not supplied in the params' do
          before { task.groups << group }

          let(:group_tasks_params) { {group_ids: ['']} }

          it 'removes the group from the Task' do
            expect { put_update }.to change { task.reload.groups }.from(contain_exactly(group)).to(be_empty)
          end
        end

        context 'when task has a group and it is not supplied in the params and the user cannot remove the task from the group (does not have admin rights to the group)' do
          before { task.groups << group }

          let(:group) { create(:group) }
          let(:group_tasks_params) { {group_ids: ['']} }

          it 'does not remove the group from the Task' do
            expect { put_update }.not_to change { task.reload.groups.map(&:id) }
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

      context 'when task is a contribution' do
        let!(:contribution) { create(:task_contribution, suggestion: task) }

        it 'redirects the user to the contribution' do
          put_update
          expect(response).to redirect_to([contribution.base, contribution])
        end
      end
    end

    context 'with invalid params' do
      subject(:put_update) { put :update, params: {id: task.to_param, task: invalid_attributes, group_tasks: {group_ids: ['']}} }

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

  describe 'POST #duplicate' do
    subject(:post_duplicate) { post :duplicate, params: {id: task.id} }

    before { sign_in user }

    let(:groups) { create_list(:group, 1) }
    let(:collections) { create_list(:collection, 1) }
    let!(:task) { create(:task, valid_attributes) }
    let(:valid_attributes) do
      {
        user:,
        title: 'title',
        license: create(:license, name: 'license'),
        groups:,
        collections:,
      }
    end

    it 'creates a new Task' do
      expect { post_duplicate }.to change(Task, :count).by(1)
    end

    it 'assigns a newly created task as @task' do
      post_duplicate
      expect(assigns(:task)).to be_persisted
    end

    it 'redirects to the created task' do
      post_duplicate
      expect(response).to redirect_to(Task.find_by(parent_uuid: task.uuid))
    end

    it 'resets the groups' do
      post_duplicate
      expect(Task.find_by(parent_uuid: task.uuid).groups).to eq([])
    end

    it 'resets the collections' do
      post_duplicate
      expect(Task.find_by(parent_uuid: task.uuid).collections).to eq([])
    end

    context 'when saving fails' do
      let(:invalid_task) { Task.new }

      before do
        # We need to stub the find method, because otherwise another object is returned from the database
        allow(Task).to receive(:find).with(task.id.to_s).and_return(task)
        # By design, we return an invalid task, which will fail to save
        allow(task).to receive(:clean_duplicate).with(user).and_return(invalid_task)
      end

      it 'shows an error message' do
        post_duplicate
        expect(flash[:alert]).to eq(I18n.t('tasks.duplicate.error_alert'))
      end
    end
  end

  describe 'DELETE #destroy' do
    subject(:delete_request) do
      delete :destroy, params: {id: task.to_param}
    end

    before { sign_in user }

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
    subject(:get_request) { get :download, params: {id: task.id, version: proforma_version} }

    let(:task) { create(:task, valid_attributes) }
    let(:zip) { instance_double(StringIO, string: 'dummy') }
    let(:proforma_version) { '2.1' }

    before { allow(ProformaService::ExportTask).to receive(:call).with(task:, options: {version: proforma_version}).and_return(zip) }

    context 'when not signed in' do
      it 'redirects to user sign in page' do
        expect(get_request).to redirect_to(new_user_session_path)
      end

      context 'when task is public' do
        let(:access_level) { :public }

        it 'sends the correct data' do
          get_request
          expect(response.body).to eql 'dummy'
        end
      end
    end

    context 'when signed in' do
      before { sign_in user }

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

      context 'when proforma_version is 2.0' do
        let(:proforma_version) { '2.0' }

        it 'sends the correct data' do
          get_request
          expect(response.body).to eql 'dummy'
        end
      end

      context 'when export task raises an error' do
        before { allow(ProformaService::ExportTask).to receive(:call).with(task:, options: {version: proforma_version}).and_raise(ProformaXML::PostGenerateValidationError, '["version not supported"]') }

        it 'redirects to root' do
          get_request
          expect(response).to redirect_to(root_path)
        end

        it 'sets the correct flash message' do
          expect { get_request }.to change { flash[:danger] }.to(I18n.t('proforma_errors.version not supported'))
        end
      end
    end
  end

  describe 'POST #import_start' do
    render_views

    subject(:post_request) { post :import_start, params: {zip_file:}, format: :js, xhr: true }

    before do
      sign_in user
      allow(ProformaService::CacheImportFile).to receive(:call).and_call_original
    end

    let(:zip_file) { fixture_file_upload('proforma_import/testfile.zip', 'application/zip') }

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

      it 'renders correct JSON' do
        post_request
        expect(JSON.parse(response.body, symbolize_names: true)).to eql({status: 'failure', message: 'You need to choose a file.'})
      end
    end

    context "when zip_file is 'undefined'" do
      let(:zip_file) { 'undefined' }

      it 'renders correct JSON' do
        post_request
        expect(JSON.parse(response.body, symbolize_names: true)).to eql({status: 'failure', message: 'You need to choose a file.'})
      end
    end

    context 'when service throws version not supported error' do
      before do
        allow(ProformaService::CacheImportFile).to receive(:call).and_raise(ProformaXML::ProformaError.new(['version not supported']))
      end

      it 'renders correct JSON' do
        post_request
        expect(JSON.parse(response.body, symbolize_names: true)).to eql({status: 'failure', message: 'Import of task could not be started. <br> Error: An error occurred while importing your ProformaXML ZIP file.<br>The version of this ProformaXML document is not supported.', actions: ''})
      end
    end

    context 'when service throws an unexpected error' do
      before do
        allow(ProformaService::CacheImportFile).to receive(:call).and_raise(StandardError)
      end

      it 'renders correct JSON' do
        post_request
        expect(JSON.parse(response.body, symbolize_names: true)).to eql({status: 'failure', message: 'An internal error occurred on CodeHarbor while importing the exercise.', actions: ''})
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

    context 'when signed in' do
      before { sign_in user }

      it 'creates the task' do
        expect { post_request }.to change(Task, :count).by(1)
      end

      it 'renders correct JSON' do
        post_request
        expect(response.body).to include('successfully imported').and(include(I18n.t('tasks.import_actions.button.show_task')).and(include('Hide')))
      end

      context 'when import raises a validation error' do
        before { allow(ProformaService::ImportTask).to receive(:call).and_raise(ActiveRecord::RecordInvalid) }

        it 'renders correct JSON' do
          post_request
          expect(response.body).to include('failed').and(include('Record invalid').and(include('"actions":""')))
        end
      end

      context 'when service throws an unexpected error' do
        before do
          allow(ProformaService::ImportTask).to receive(:call).and_raise(StandardError)
        end

        it 'renders correct JSON' do
          post_request
          expect(JSON.parse(response.body, symbolize_names: true)).to eql({status: 'failure', message: 'An internal error occurred on CodeHarbor while importing the exercise.', actions: ''})
        end
      end
    end

    context 'when signed out' do
      it 'does not create the task' do
        expect { post_request }.not_to change(Task, :count)
      end

      it 'redirects to sign_in' do
        expect(post_request).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #import_uuid_check' do
    subject(:post_request) { post :import_uuid_check, params: {uuid:, format: :json} }

    let!(:task) { create(:task, valid_attributes) }
    let(:headers) { {'Authorization' => "Bearer #{account_link.api_key}"} }
    let(:account_link) { create(:account_link, user:) }
    let(:uuid) { task.reload.uuid }

    before { request.headers.merge! headers }

    it 'renders correct response' do
      post_request
      expect(response).to have_http_status(:success)

      expect(response.parsed_body.symbolize_keys).to eql(uuid_found: true, update_right: true)
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

        expect(response.parsed_body.symbolize_keys).to eql(uuid_found: true, update_right: false)
      end
    end

    context 'when the searched task does not exist' do
      let(:uuid) { 'anotheruuid' }

      it 'renders correct response' do
        post_request
        expect(response).to have_http_status(:success)

        expect(response.parsed_body.symbolize_keys).to eql(uuid_found: false)
      end
    end
  end

  describe 'POST #import_external' do
    subject(:post_request) { post :import_external, body: zip_file_content }

    let(:account_link) { create(:account_link, user:) }
    let(:zip_file_content) { 'zipped task xml' }
    let(:headers) { {'Authorization' => "Bearer #{account_link.api_key}"} }

    before do
      sign_in user
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
      before { allow(ProformaService::Import).to receive(:call).and_raise(ProformaXML::PreImportValidationError) }

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
    before { sign_in user }

    let(:task) { create(:task, valid_attributes) }
    let(:account_link) { create(:account_link, user: account_link_user) }
    let(:account_link_user) { user }
    let(:get_request) do
      get :export_external_start, params: {id: task.id, account_link: account_link.id}, format: :js, xhr: true
    end

    shared_examples 'renders success response' do
      it 'renders export_external_start javascript' do
        get_request
        expect(response).to render_template('export_external_start')
      end
    end

    include_examples 'renders success response'

    context 'when the account link is shared with the requesting user' do
      let(:account_link) { create(:account_link, user: create(:user), shared_users: Array.wrap(user)) }

      include_examples 'renders success response'
    end

    context 'when the account link is neither owned by nor shared with the requesting user' do
      let(:account_link_user) { create(:user) }

      it 'does not render export_external_start javascript' do
        get_request
        expect(response).not_to render_template('export_external_start')
      end
    end
  end

  describe 'POST #export_external_check' do
    render_views

    before do
      sign_in user
      allow(TaskService::CheckExternal).to receive(:call).with(uuid: task.uuid,
        account_link:).and_return(external_check_hash)
    end

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

    shared_examples 'renders success json' do
      it 'renders the correct contents as JSON' do
        post_request
        expect(response.parsed_body.symbolize_keys[:message]).to eq('message')
        expect(response.parsed_body.symbolize_keys[:actions]).to(
          include('button').and(include('Abort').and(include('Overwrite')).and(include('Create new')))
        )
        expect(response.parsed_body.symbolize_keys[:actions]).to(
          not_include('Retry').and(not_include('Hide'))
        )
      end
    end

    include_examples 'renders success json'

    context 'when there is an error' do
      let(:error) { 'error' }

      it 'renders the correct contents as JSON' do
        post_request
        expect(response.parsed_body.symbolize_keys[:message]).to eq('message')
        expect(response.parsed_body.symbolize_keys[:actions]).to(
          include('button').and(include('Abort')).and(include('Retry'))
        )
        expect(response.parsed_body.symbolize_keys[:actions]).to(
          not_include('Overwrite').and(not_include('Create new')).and(not_include('Export')).and(not_include('Hide'))
        )
      end
    end

    context 'when uuid_found is false' do
      let(:uuid_found) { false }

      it 'renders the correct contents as JSON' do
        post_request
        expect(response.parsed_body.symbolize_keys[:message]).to eq('message')
        expect(response.parsed_body.symbolize_keys[:actions]).to(
          include('button').and(include('Abort')).and(include('Export'))
        )
        expect(response.parsed_body.symbolize_keys[:actions]).to(
          not_include('Overwrite').and(not_include('Create new')).and(not_include('Hide'))
        )
      end
    end

    context 'when the account link is shared with the requesting user' do
      let(:account_link) { create(:account_link, user: create(:user), shared_users: Array.wrap(user)) }

      include_examples 'renders success json'
    end

    context 'when the account link is neither owned by nor shared with the requesting user' do
      let(:account_link_user) { create(:user) }

      it 'renders the correct not authorized JSON' do
        post_request
        expect(response.parsed_body.symbolize_keys[:error]).to eq('You are not authorized for this action.')
      end
    end
  end

  describe 'POST #export_external_confirm' do
    render_views

    before do
      sign_in user
      allow(ProformaService::ExportTask).to receive(:call)
        .with(task: an_instance_of(Task), options: {description_format: 'md', version: export_proforma_version})
        .and_return('zip stream')
      allow(TaskService::PushExternal).to receive(:call)
        .with(zip: 'zip stream', account_link:)
        .and_return(error)
    end

    let(:proforma_version) {}
    let(:export_proforma_version) { '2.1' }
    let!(:task) { create(:task, valid_attributes) }
    let(:account_link) { create(:account_link, user: account_link_user, proforma_version:) }
    let(:account_link_user) { user }
    let(:post_request) do
      post :export_external_confirm, params: {push_type:, id: task.id, account_link: account_link.id}, format: :json,
        xhr: true
    end
    let(:push_type) { 'export' }
    let(:error) {}

    shared_examples 'renders success response' do
      it 'renders correct response' do
        post_request

        expect(response).to have_http_status(:success)
        expect(response.parsed_body.symbolize_keys[:message]).to(include('successfully exported'))
        expect(response.parsed_body.symbolize_keys[:status]).to(eql('success'))
        expect(response.parsed_body.symbolize_keys[:actions]).to(include('button').and(include('Hide')))
        expect(response.parsed_body.symbolize_keys[:actions]).to(not_include('Retry').and(not_include('Abort')))
      end
    end

    it 'does not create a new task' do
      expect { post_request }.not_to change(Task, :count)
    end

    include_examples 'renders success response'

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
        expect(response.parsed_body.symbolize_keys[:message]).to(include('failed').and(include('exampleerror')))
        expect(response.parsed_body.symbolize_keys[:status]).to(eql('fail'))
        expect(response.parsed_body.symbolize_keys[:actions]).to(include('button').and(include('Retry')).and(include('Abort')))
        expect(response.parsed_body.symbolize_keys[:actions]).to(not_include('Hide'))
      end
    end

    context 'without push_type' do
      let(:push_type) {}

      it 'responds with status 500' do
        post_request
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when the account link is shared with the requesting user' do
      let(:account_link) { create(:account_link, user: create(:user), shared_users: Array.wrap(user)) }

      include_examples 'renders success response'
    end

    context 'when the account link is neither owned by nor shared with the requesting user' do
      let(:account_link_user) { create(:user) }

      it 'renders the correct not authorized JSON' do
        post_request
        expect(response.parsed_body.symbolize_keys[:error]).to eq('You are not authorized for this action.')
      end
    end

    context 'when proforma_version is set' do
      let(:proforma_version) { '2.1' }

      it 'renders correct response' do
        post_request

        expect(response).to have_http_status(:success)
      end

      context 'when proforma_version is 2.0' do
        let(:proforma_version) { '2.0' }
        let(:export_proforma_version) { '2.0' }

        it 'renders correct response' do
          post_request

          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'POST #add_to_collection' do
    before { sign_in user }

    let!(:task) { create(:task, valid_attributes) }
    let(:valid_session) { {user_id: collection.users.first.id} }

    it 'adds task to collection' do
      expect do
        post :add_to_collection, params: {id: task.to_param, collection: collection.id}, session: valid_session
      end.to change(collection.tasks, :count).by(+1)
    end
  end

  describe 'POST #generate_test' do
    let(:task_user) { create(:user, openai_api_key: 'valid_api_key') }
    let(:access_level) { :public }
    let(:task) { create(:task, user: task_user, access_level:) }
    let(:mock_models) { instance_double(OpenAI::Models, list: {'data' => [{'id' => 'model-id'}]}) }

    before do
      allow(OpenAI::Client).to receive(:new).and_return(instance_double(OpenAI::Client, models: mock_models))
      sign_in task_user
    end

    context 'when GptGenerateTests is successful' do
      before do
        allow(GptService::GenerateTests).to receive(:call)
        post :generate_test, params: {id: task.id}
      end

      it 'calls the GptGenerateTests service with the correct parameters' do
        expect(GptService::GenerateTests).to have_received(:call).with(task:, openai_api_key: 'valid_api_key')
      end

      it 'redirects to the task show page' do
        expect(response).to redirect_to(task_path(task))
      end

      it 'sets flash to the appropriate message' do
        expect(flash[:notice]).to eq(I18n.t('tasks.task_service.gpt_generate_tests.successful_generation'))
      end
    end

    context 'when GptGenerateTests raises Gpt::Error::MissingLanguage' do
      before do
        allow(GptService::GenerateTests).to receive(:call).and_raise(Gpt::Error::MissingLanguage)
        post :generate_test, params: {id: task.id}
      end

      it 'redirects to the task show page' do
        expect(response).to redirect_to(task_path(task))
      end

      it 'sets flash to the appropriate message' do
        expect(flash[:alert]).to eq(I18n.t('errors.gpt.missing_language'))
      end
    end

    context 'when GptGenerateTests raises Gpt::Error::InvalidTaskDescription' do
      before do
        allow(GptService::GenerateTests).to receive(:call).and_raise(Gpt::Error::InvalidTaskDescription)
        post :generate_test, params: {id: task.id}
      end

      it 'redirects to the task show page' do
        expect(response).to redirect_to(task_path(task))
      end

      it 'sets flash to the appropriate message' do
        expect(flash[:alert]).to eq(I18n.t('errors.gpt.invalid_task_description'))
      end
    end
  end
end
