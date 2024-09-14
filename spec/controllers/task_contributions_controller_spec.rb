# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskContributionsController do
  render_views

  let(:contribution_user) { create(:user) }
  let(:user) { contribution_user }
  let(:original_author) { create(:user) }
  let!(:task) { create(:task, :with_meta_data, :with_submission_restrictions, :with_external_resources, :with_grading_hints, user: original_author, access_level: 'public') }
  let(:contrib_task) { build(:task, user: contribution_user, title: 'Modified title', parent_uuid: task.uuid) }
  let(:contribution) { build(:task_contribution, suggestion: contrib_task, base: task, status: :pending) }

  before { sign_in user }

  describe 'GET #index' do
    subject(:get_request) { get :index, params: {task_id: task.id} }

    let(:user) { original_author }

    context 'without any task contributions' do
      before { get_request }

      expect_assigns(task: :task, task_contributions: [])
      expect_http_status(:success)
      expect_template(:index)
    end

    context 'with task contributions' do
      before do
        contribution.save!
        get_request
      end

      expect_assigns(task: :task, task_contributions: TaskContribution.all)
      expect_http_status(:success)
      expect_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new task as @task' do
      get :new, params: {task_id: task.id}
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe 'POST #create' do
    subject(:post_request) { post :create, params: {task_id: task.id, task: task_params} }

    let(:task_params) { attributes_for(:task) }
    let(:suggestion) { assigns(:task_contribution).suggestion }

    context 'with valid params' do
      it 'creates a new Task and TaskContribution' do
        expect { post_request }
          .to change(Task, :count).by(1)
          .and change(TaskContribution, :count).by(1)
      end

      it 'assigns a newly created suggestion as @task_contribution.suggestion' do
        post_request
        expect(suggestion).to be_a(Task)
        expect(suggestion).to be_persisted
      end

      it 'changes required parameters' do
        post_request
        expect(suggestion.access_level).to eq('private')
        expect(suggestion.user).to eq(user)
        expect(suggestion.parent_uuid).to eq(task.uuid)
        expect(suggestion.task_contribution).not_to be_nil
        expect(suggestion.task_contribution.status).to eq('pending')
      end

      it 'keeps the original task metadata' do
        post_request
        expect(suggestion.meta_data).to eq(task.meta_data)
        expect(suggestion.submission_restrictions).to eq(task.submission_restrictions)
        expect(suggestion.external_resources).to eq(task.external_resources)
        expect(suggestion.grading_hints).to eq(task.grading_hints)
      end

      it 'redirects to the created task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to([assigns(:task), assigns(:task_contribution)])
      end
    end

    context 'when new task is invalid' do
      let(:task_params) { {title: ''} }

      it 'shows validation errors' do
        post_request
        expect(assigns(:task).errors.messages).to include(:title)
      end

      it 'renders the form again' do
        post_request
        expect(response).to render_template('tasks/new')
      end
    end
  end

  describe 'POST #approve_changes' do
    let(:user) { original_author }

    before do
      task.save!
      contribution.save!
    end

    context 'when apply_contribution is successful' do
      subject(:post_request) { post :approve_changes, params: {task_id: task.id, id: contribution.id} }

      it 'changes the contribution status' do
        post_request
        expect(TaskContribution.find(contribution.id).status).to eq('merged')
      end

      it 'redirects to the original task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(task)
      end
    end

    context 'when apply_contribution fails' do
      subject(:post_request) { post :approve_changes, params: {task_id: task.id, id: contribution.id} }

      before do
        allow(Task).to receive(:find).with(task.id.to_s).and_return(task)
        allow(task).to receive(:apply_contribution).and_return(false)
      end

      it 'shows a flash message' do
        post_request
        expect(flash[:alert]).to eq(I18n.t('task_contributions.approve_changes.error'))
      end

      it 'redirects to the modified task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to([task, contribution])
      end
    end
  end

  describe 'POST #discard_changes' do
    before do
      task.save!
      contribution.save!
    end

    context 'with valid params' do
      subject(:post_request) { post :discard_changes, params: {task_id: task.id, id: contribution.id} }

      it 'changes the contribution status' do
        post_request
        expect(TaskContribution.find(contribution.id).status).to eq('closed')
      end

      it 'duplicates the task' do # The duplication is tested in the Task model
        expect { post_request }.to change(Task, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when TaskContribution.decouple fails' do
      subject(:post_request) { post :discard_changes, params: {task_id: task.id, id: contribution.id} }

      before do
        allow(TaskContribution).to receive(:find).with(contribution.id.to_s).and_return(contribution)
        allow(contribution).to receive(:decouple).and_return(false)
      end

      it 'shows a flash message' do
        post_request
        expect(flash[:alert]).to eq(I18n.t('task_contributions.discard_changes.error'))
      end

      it 'redirects to the modified task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to([task, contribution])
      end
    end
  end

  describe 'POST #reject_changes' do
    let(:user) { original_author }

    before do
      task.save!
      contribution.save!
    end

    context 'with valid params' do
      subject(:post_request) { post :reject_changes, params: {task_id: task.id, id: contribution.id} }

      it 'changes the contribution status' do
        post_request
        expect(TaskContribution.find(contribution.id).status).to eq('closed')
      end

      it 'delivers a rejection email' do
        expect { post_request }.to have_enqueued_email(TaskContributionMailer, :send_rejection_info)
      end

      it 'duplicates the task' do # The duplication is tested in the Task model
        expect { post_request }.to change(Task, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when TaskContribution.decouple fails' do
      subject(:post_request) { post :reject_changes, params: {task_id: task.id, id: contribution.id} }

      before do
        allow(TaskContribution).to receive(:find).with(contribution.id.to_s).and_return(contribution)
        allow(contribution).to receive(:decouple).and_return(false)
      end

      it 'shows a flash message' do
        post_request
        expect(flash[:alert]).to eq(I18n.t('task_contributions.reject_changes.error'))
      end

      it 'redirects to the modified task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to([task, contribution])
      end
    end
  end

  describe 'GET #show' do
    subject(:get_request) { get :show, params: {task_id: task.id, id: contribution.id} }

    before do
      task.save!
      contribution.save!
    end

    context 'when contribution exists' do
      it 'shows the suggestions' do
        get_request
        expect(assigns(:task)).to eq(contribution.suggestion)
      end
    end
  end

  describe 'GET #edit' do
    before do
      task.save!
      contribution.save!
    end

    it 'renders the edit form' do
      get :edit, params: {task_id: task.id, id: contribution.id}
      expect(response).to render_template('tasks/edit')
    end
  end

  describe 'PUT #update' do
    subject(:put_update) { put :update, params: {task_id: task.id, id: contribution.id, task: task_params} }

    before do
      task.save!
      contribution.save!
    end

    context 'with valid params' do
      let(:task_params) { {title: 'New modified title'} }

      it 'updates the contribution' do
        put_update
        expect(contribution.reload.suggestion.title).to eq('New modified title')
      end

      it 'redirects to the contribution' do
        put_update
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to([task, contribution])
      end
    end

    context 'with invalid params' do
      let(:task_params) { {title: ''} }

      it 'renders the edit form' do
        put_update
        expect(response).to render_template('tasks/edit')
      end
    end
  end
end
