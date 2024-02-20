# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskContributionsController do
  render_views

  let(:user) { create(:user) }
  let(:original_author) { create(:user) }
  let!(:task) { create(:task, user: original_author, access_level: 'public') }
  let(:contrib_task) { build(:task, user:, title: 'Modified title', parent_uuid: task.uuid) }
  let(:contribution) { build(:task_contribution, suggestion: contrib_task, status: :pending) }

  before { sign_in user }

  describe 'GET #new' do
    # let(:ot) {create(:task, user: original_author)}
    # let(:ct) {create(:task, user: user, parent_uuid: ot.uuid)}
    let(:tc) { create(:task_contribution, status: :pending) }

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

      it 'redirects to the created task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to([assigns(:task), assigns(:task_contribution)])
      end
    end

    context 'when new task is invalid' do
      let(:task_params) { {title: ''} }

      it 'shows a flash message' do
        post_request
        expect(flash[:alert]).to eq(I18n.t('task_contributions.create.error'))
      end

      it 'redirects to the original task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(task)
      end
    end
  end

  describe 'POST #approve_changes' do
    let(:user) { original_author }

    before do
      task.save!
      contribution.save!
    end

    context 'with valid params' do
      subject(:post_request) { post :approve_changes, params: {task_id: task.id, id: contribution.id} }

      it 'changes the original task, but retains certain fields' do
        post_request
        expect(assigns(:task).id).to eq(task.id)
      end

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
        allow(task).to receive(:apply_contribution).with(contribution).and_return(false)
      end

      it 'shows a flash message' do
        post_request
        expect(flash[:alert]).to eq(I18n.t('task_contributions.approve_changes.error'))
      end

      it 'redirects to the modifying task' do
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

      it 'redirects to the modified task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to([task, contribution])
      end
    end

    context 'when TaskContribution.close fails' do
      subject(:post_request) { post :discard_changes, params: {task_id: task.id, id: contribution.id} }

      before do
        allow(TaskContribution).to receive(:find).with(contribution.id.to_s).and_return(contribution)
        allow(contribution).to receive(:close).and_return(false)
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
      sign_in user
    end

    it 'renders the edit form' do
      get :edit, params: {task_id: task.id, id: contribution.id}
      expect(response).to render_template('tasks/edit')
    end
  end

  describe 'PUT #update' do
    subject(:put_update) { put :update, params: {task_id: task.id, id: contribution.id, task: task_params} }

    before do
      sign_in user
      task.save!
      contribution.save!
    end

    context 'with valid params' do
      let(:task_params) { {title: 'New modified title'} }

      it 'updates the contribution' do
        expect(put_update).to change { contribution.reload.suggestion.title }.to('New modified title')
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
