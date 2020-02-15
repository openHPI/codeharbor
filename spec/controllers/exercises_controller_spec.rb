# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExercisesController, type: :controller do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user: user, exercises: []) }
  let(:collection) { create(:collection, users: [user], exercises: []) }
  # This should return the minimal set of attributes required to create a valid
  # Exercise. As you add validations to Exercise, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    FactoryBot.attributes_for(:only_meta_data, user: user).merge(
      descriptions_attributes: {'0' => FactoryBot.attributes_for(:simple_description, :primary)}
    )
  end

  let(:invalid_attributes) do
    {title: ''}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ExercisesController. Be sure to keep this updated too.
  let(:valid_session) do
    {user_id: user.id}
  end

  describe 'GET #index (My Exercises)' do
    subject(:get_request) { get :index, params: params, session: valid_session }

    let(:get_request_without_params) { get :index, params: {}, session: valid_session }
    let!(:exercise) { create(:simple_exercise, valid_attributes) }
    let(:params) { {} }

    it 'shows all Exercises of that user' do
      get_request
      expect(assigns(:exercises)).to contain_exactly exercise
    end

    context 'when user has multiple exercises' do
      before { create(:simple_exercise, valid_attributes) }

      it 'shows all Exercises of that user' do
        get_request
        expect(assigns(:exercises).size).to eq 2
      end

      context 'when a filter is used' do
        let(:params) { {search: 'filter'} }
        let!(:exercise) { create(:simple_exercise, user: user, title: 'filter me') }

        it 'shows the matching Exercise' do
          get_request
          expect(assigns(:exercises)).to contain_exactly exercise
        end

        context 'when a second request without searchparams is made' do
          it 'shows the matching Exercise' do
            get_request
            get_request_without_params
            expect(assigns(:exercises)).to contain_exactly exercise
          end
        end
      end
    end
  end

  describe 'GET #show' do
    let!(:exercise) { create(:simple_exercise, valid_attributes) }
    let(:get_request) { get :show, params: {id: exercise.to_param}, session: valid_session }

    it 'assigns the requested exercise to instance variable' do
      get_request
      expect(assigns(:exercise)).to eq(exercise)
    end

    context 'when exercise has an exercises_file' do
      let!(:file) { create(:exercise_file, exercise: exercise) }

      it "assigns exercise's files to instance variable" do
        get_request
        expect(assigns(:files)).to include(file)
      end
    end

    context 'when exercise has a test' do
      let!(:test) { create(:test, exercise: exercise) }

      it "assigns exercise's tests to instance variable" do
        get_request
        expect(assigns(:tests)).to include(test)
      end
    end

    context 'when user has rated exercise before' do
      let!(:rating) { create(:rating, user: user, exercise: exercise) }

      it 'assigns user_rating to instance variable' do
        get_request
        expect(assigns(:user_rating)).to eq(rating.rating)
      end
    end

    context 'when exercise has been cloned' do
      let!(:cloned_exercise) { create(:simple_exercise) }
      let!(:relation) { create(:exercise_relation, origin: exercise, clone: cloned_exercise) }

      it 'assigns user_rating to instance variable' do
        get :show, params: {id: cloned_exercise.to_param}, session: valid_session
        expect(assigns(:exercise_relation)).to eq(relation).and(be_a(ExerciseRelation))
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new exercise as @exercise' do
      get :new, params: {}, session: valid_session
      expect(assigns(:exercise)).to be_a_new(Exercise)
    end
  end

  describe 'GET #edit' do
    let!(:exercise) { create(:simple_exercise, valid_attributes) }

    it 'assigns the requested exercise as @exercise' do
      get :edit, params: {id: exercise.to_param}, session: valid_session
      expect(assigns(:exercise)).to eq(exercise)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          title: 'title',
          descriptions_attributes: {'0' => {text: 'description', primary: true}},
          execution_environment_id: create(:java_8_execution_environment).id,
          license_id: create(:license)
        }
      end

      it 'creates a new Exercise' do
        expect do
          post :create, params: {exercise: valid_params}, session: valid_session
        end.to change(Exercise, :count).by(1)
      end

      it 'assigns a newly created exercise as @exercise' do
        post :create, params: {exercise: valid_params}, session: valid_session
        expect(assigns(:exercise)).to be_persisted
      end

      it 'redirects to the created exercise' do
        post :create, params: {exercise: valid_params}, session: valid_session
        expect(response).to redirect_to(Exercise.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved exercise as @exercise' do
        post :create, params: {exercise: invalid_attributes}, session: valid_session
        expect(assigns(:exercise)).to be_a_new(Exercise)
      end

      it "re-renders the 'new' template" do
        post :create, params: {exercise: invalid_attributes}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    let(:update_attributes) do
      FactoryBot.attributes_for(:only_meta_data, user: user).merge(
        descriptions_attributes: {'0' => FactoryBot.attributes_for(:simple_description)},
        title: 'new_title'
      )
    end
    let!(:exercise) { create(:simple_exercise, valid_attributes) }

    context 'with valid params' do
      it 'updates the requested exercise' do
        put :update, params: {id: exercise.to_param, exercise: update_attributes}, session: valid_session
        exercise.reload
        expect(exercise.title).to eq 'new_title'
      end

      it 'assigns the requested exercise as @exercise' do
        put :update, params: {id: exercise.to_param, exercise: update_attributes}, session: valid_session
        expect(assigns(:exercise)).to eq(exercise)
      end

      it 'redirects to the exercise' do
        put :update, params: {id: exercise.to_param, exercise: update_attributes}, session: valid_session
        expect(response).to redirect_to(exercise)
      end

      it 'creates a predecessor of the exercise' do
        expect { put :update, params: {id: exercise.to_param, exercise: update_attributes}, session: valid_session }.to change {
          exercise.reload.predecessor
        }.from(nil).to(be_an Exercise)
      end

      context 'when exercise has a test' do
        let(:test) { build(:codeharbor_test) }
        let!(:exercise) { create(:simple_exercise, update_attributes.merge(tests: [test], descriptions: [build(:description, :primary)])) }

        let(:new_attributes) { {title: 'new title', tests_attributes: tests_attributes} }
        let(:tests_attributes) { {'0' => test.attributes.merge('exercise_file_attributes' => test.exercise_file.attributes)} }

        let(:put_update) { put :update, params: {id: exercise.to_param, exercise: new_attributes}, session: valid_session }

        it 'updates the requested exercise' do
          expect { put_update }.to change { exercise.reload.title }.to('new title')
        end
      end
    end

    context 'with invalid params' do
      it 'assigns the exercise as @exercise' do
        put :update, params: {id: exercise.to_param, exercise: invalid_attributes}, session: valid_session
        expect(assigns(:exercise)).to eq(exercise)
      end

      it "re-renders the 'edit' template" do
        put :update, params: {id: exercise.to_param, exercise: invalid_attributes}, session: valid_session
        expect(response).to render_template('edit')
      end
    end

    context 'when exercise has a state' do
      before { exercise.update(state_list: 'new') }

      let(:put_update) { put :update, params: {id: exercise.to_param, exercise: {title: 'updated title'}}, session: valid_session }

      it 'removes the state' do
        expect { put_update }.to change { exercise.reload.state_list }.from(['new']).to(be_empty)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:exercise) { create(:simple_exercise, valid_attributes) }

    it 'destroys the requested exercise' do
      expect do
        delete :destroy, params: {id: exercise.to_param}, session: valid_session
      end.to change(Exercise, :count).by(-1)
    end

    it 'redirects to the exercises list' do
      delete :destroy, params: {id: exercise.to_param}, session: valid_session
      expect(response).to redirect_to(exercises_url)
    end
  end

  describe 'POST #add_to_cart' do
    let!(:exercise) { create(:simple_exercise, valid_attributes) }

    it 'adds exercise to cart' do
      expect do
        post :add_to_cart, params: {id: exercise.to_param}, session: valid_session
      end.to change(cart.exercises, :count).by(+1)
    end
  end

  describe 'POST #add_to_collection' do
    let!(:exercise) { create(:simple_exercise, valid_attributes) }

    it 'adds exercise to collection' do
      expect do
        post :add_to_collection, params: {id: exercise.to_param, collection: collection.id}, session: valid_session
      end.to change(collection.exercises, :count).by(+1)
    end
  end

  describe 'POST #remove_state' do
    let!(:exercise) { create(:simple_exercise, user: user, state_list: state_list) }
    let(:state_list) {}
    let(:post_query) { post :remove_state, params: {id: exercise.to_param}, session: valid_session }

    it 'does not change states' do
      expect { post_query }.not_to(change { exercise.reload.state_list })
    end

    context 'when exercise has new-state' do
      let(:state_list) { 'new' }

      it 'does not change states' do
        expect { post_query }.to change { exercise.reload.state_list }.from(['new']).to([])
      end
    end

    context 'when exercise has updated-state' do
      let(:state_list) { 'updated' }

      it 'does not change states' do
        expect { post_query }.to change { exercise.reload.state_list }.from(['updated']).to([])
      end
    end
  end

  describe '#download_exercise' do
    let(:exercise) { create(:simple_exercise) }

    let(:get_request) { get :download_exercise, params: {id: exercise.id}, session: valid_session }
    let(:zip) { instance_double('StringIO', string: 'dummy') }

    before { allow(ProformaService::ExportTask).to receive(:call).with(exercise: exercise).and_return(zip) }

    it do
      get_request
      expect(ProformaService::ExportTask).to have_received(:call)
    end

    it 'updates download count' do
      expect { get_request }.to change { exercise.reload.downloads }.by(1)
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
      expect(response.header['Content-Disposition']).to include "attachment; filename=\"task_#{exercise.id}.zip\""
    end
  end

  describe '#history' do
    let(:exercise) { create(:simple_exercise, valid_attributes) }
    let(:get_request) { get :history, params: {id: exercise.id}, session: valid_session, format: :js, xhr: true }

    before { exercise }

    it 'sets complete history of exercise into history_exercises' do
      get_request
      expect(assigns(:history_exercises)).to contain_exactly(include(exercise: exercise, version: 'selected'))
    end

    it 'renders load_history javascript' do
      get_request
      expect(response).to render_template('load_history.js.erb')
    end

    context 'when history is large' do
      let(:exercise) do
        create(
          :simple_exercise,
          valid_attributes.merge(
            predecessor: build(:simple_exercise,
                               predecessor: build(:simple_exercise, user: user), user: user)
          )
        )
      end

      it 'sets complete history of exercise into history_exercises' do
        get_request
        expect(assigns(:history_exercises)).to have(3).items.and(
          contain_exactly({exercise: exercise, version: 'selected'}, {exercise: exercise.predecessor, version: 2},
                          exercise: exercise.predecessor.predecessor, version: 1)
        )
      end

      context 'when history for the middle exercise is requested' do
        let(:get_request) { get :history, params: {id: exercise.predecessor.id}, session: valid_session, format: :js, xhr: true }

        it 'sets complete history of exercise into history_exercises' do
          get_request
          expect(assigns(:history_exercises)).to have(3).items.and(
            contain_exactly({exercise: exercise, version: 'latest'}, {exercise: exercise.predecessor, version: 'selected'},
                            exercise: exercise.predecessor.predecessor, version: 1)
          )
        end
      end
    end
  end

  describe '#export_external_start' do
    let(:exercise) { create(:simple_exercise, valid_attributes) }
    let(:account_link) { create(:account_link, user: account_link_user) }
    let(:account_link_user) { user }
    let(:get_request) do
      get :export_external_start, params: {id: exercise.id, account_link: account_link.id}, session: valid_session, format: :js, xhr: true
    end

    it 'renders export_external_start javascript' do
      get_request
      expect(response).to render_template('export_external_start')
    end

    context 'when account link has another user' do
      let(:account_link_user) { create(:user) }

      it 'redirects back to exercise' do
        get_request
        expect(response).to redirect_to(exercise)
      end

      it 'shows flash message' do
        get_request
        expect(get_request.request.flash[:alert]).to eql I18n.t('controllers.exercise.account_link_authorization')
      end

      context 'when account_link is shared' do
        before { create(:account_link_user, account_link: account_link, user: user) }

        it 'renders export_external_start javascript' do
          get_request
          expect(response).to render_template('export_external_start')
        end
      end
    end
  end

  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable RSpec/MultipleExpectations
  RSpec::Matchers.define_negated_matcher :not_include, :include

  describe '#export_external_check' do
    render_views

    let!(:exercise) { create(:simple_exercise, valid_attributes).reload }
    let(:account_link) { create(:account_link, user: account_link_user) }
    let(:account_link_user) { user }
    let(:post_request) do
      post :export_external_check, params: {id: exercise.id, account_link: account_link.id}, session: valid_session,
                                   format: :json, xhr: true
    end
    let(:external_check_hash) { {message: message, exercise_found: exercise_found, update_right: true, error: error} }
    let(:message) { 'message' }
    let(:exercise_found) { true }
    let(:error) { nil }
    # let(:headers) { {'Accept' => 'application/json', 'Content-Type' => 'application/json'} }

    before do
      # request.headers.merge! headers
      allow(ExerciseService::CheckExternal).to receive(:call).with(uuid: exercise.uuid, account_link: account_link)
                                                             .and_return(external_check_hash)
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

    context 'when exercise_found is false' do
      let(:exercise_found) { false }

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

    context 'when account link has another user' do
      let(:account_link_user) { create(:user) }

      it 'reponds with the error' do
        post_request
        expect(JSON.parse(response.body).symbolize_keys[:error]).to eq(I18n.t('controllers.exercise.account_link_authorization'))
      end

      context 'when account_link is shared' do
        before { create(:account_link_user, account_link: account_link, user: user) }

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
      end
    end
  end

  describe '#export_external_confirm' do
    render_views

    let(:exercise) { create(:simple_exercise, valid_attributes) }
    let(:account_link) { create(:account_link, user: account_link_user) }
    let(:account_link_user) { user }
    let(:post_request) do
      post :export_external_confirm, params: {push_type: push_type, id: exercise.id, account_link: account_link.id},
                                     session: valid_session, format: :json, xhr: true
    end
    let(:push_type) { 'create_new' }
    let(:error) {}

    before do
      allow(ProformaService::HandleExportConfirm).to receive(:call)
        .with(user: user, exercise: exercise, push_type: push_type, account_link_id: account_link.to_param)
        .and_return([exercise, error])
    end

    it 'renders correct response' do
      post_request

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).symbolize_keys[:message]).to(include('successfully exported'))
      expect(JSON.parse(response.body).symbolize_keys[:status]).to(eql('success'))
      expect(JSON.parse(response.body).symbolize_keys[:actions]).to(include('button').and(include('Hide')))
      expect(JSON.parse(response.body).symbolize_keys[:actions]).to(not_include('Retry').and(not_include('Abort')))
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

    context 'when account link has another user' do
      let(:account_link_user) { create(:user) }

      it 'reponds with the error' do
        post_request
        expect(JSON.parse(response.body).symbolize_keys[:error]).to eq(I18n.t('controllers.exercise.account_link_authorization'))
      end

      context 'when account_link is shared' do
        before { create(:account_link_user, account_link: account_link, user: user) }

        it 'renders correct response' do
          post_request

          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body).symbolize_keys[:message]).to(include('successfully exported'))
          expect(JSON.parse(response.body).symbolize_keys[:status]).to(eql('success'))
          expect(JSON.parse(response.body).symbolize_keys[:actions]).to(include('button').and(include('Hide')))
          expect(JSON.parse(response.body).symbolize_keys[:actions]).to(not_include('Retry').and(not_include('Abort')))
        end
      end
    end
  end

  describe '#import_uuid_check' do
    let!(:exercise) { create(:simple_exercise, valid_attributes) }
    let(:account_link) { create(:account_link, user: user) }
    let(:uuid) { exercise.reload.uuid }
    let(:post_request) { post :import_uuid_check, params: {uuid: uuid} }
    let(:headers) { {'Authorization' => "Bearer #{account_link.api_key}"} }

    before { request.headers.merge! headers }

    it 'renders correct response' do
      post_request
      expect(response).to have_http_status(:success)

      expect(JSON.parse(response.body).symbolize_keys).to eql(exercise_found: true, update_right: true)
    end

    context 'when api_key is incorrect' do
      let(:headers) { {'Authorization' => 'Bearer XXXXXX'} }

      it 'renders correct response' do
        post_request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is cannot update the exercise' do
      let(:account_link) { create(:account_link, api_key: 'anotherkey') }

      it 'renders correct response' do
        post_request
        expect(response).to have_http_status(:success)

        expect(JSON.parse(response.body).symbolize_keys).to eql(exercise_found: true, update_right: false)
      end
    end

    context 'when the searched exercise does not exist' do
      let(:uuid) { 'anotheruuid' }

      it 'renders correct response' do
        post_request
        expect(response).to have_http_status(:success)

        expect(JSON.parse(response.body).symbolize_keys).to eql(exercise_found: false)
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength
  # rubocop:enable RSpec/MultipleExpectations

  describe 'POST #import_external_exercise' do
    let(:account_link) { create(:account_link, user: user) }

    let(:post_request) { post :import_external_exercise, body: zip_file_content }
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
      expect(ProformaService::Import).to have_received(:call).with(zip: be_a(Tempfile).and(has_content(zip_file_content)), user: user)
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

  describe 'POST #import_exercise_start' do
    render_views

    let(:post_request) { post :import_exercise_start, params: {zip_file: zip_file}, session: valid_session, format: :js, xhr: true }
    let(:zip_file) { fixture_file_upload('files/proforma_import/testfile.zip', 'application/zip') }

    before { allow(ProformaService::CacheImportFile).to receive(:call).and_call_original }

    it 'renders correct views' do
      post_request
      expect(response).to render_template('import_exercise_start', 'import_dialog_content')
    end

    it 'creates an ImportFileCache' do
      expect { post_request }.to change(ImportFileCache, :count).by(1)
    end

    it 'calls service' do
      post_request
      expect(ProformaService::CacheImportFile).to have_received(:call).with(user: user, zip_file: be_a(ActionDispatch::Http::UploadedFile))
    end

    it 'renders import view for one exercise' do
      post_request
      expect(response.body.scan('data-import-id').count).to be 1
    end

    context 'when file contains three tasks' do
      let(:zip_file) { fixture_file_upload('files/proforma_import/testfile_multi.zip', 'application/zip') }

      it 'renders import view for three exercises' do
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

  describe 'POST #import_exercise_confirm' do
    render_views

    let(:zip_file) { fixture_file_upload('files/proforma_import/testfile_multi.zip', 'application/zip') }
    let(:data) { ProformaService::CacheImportFile.call(user: user, zip_file: zip_file) }
    let(:import_data) { data.first }
    let(:post_request) do
      post :import_exercise_confirm,
           params: {import_id: import_data[1][:import_id], subfile_id: import_data[0], import_type: 'export'},
           session: valid_session, xhr: true
    end

    before { create(:file_type, file_extension: '.java') }

    it 'creates the exercise' do
      expect { post_request }.to change(Exercise, :count).by(1)
    end

    it 'renders correct json' do
      post_request
      expect(response.body).to include('successfully imported').and(include('Show exercise').and(include('Hide')))
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
