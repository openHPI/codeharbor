# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskContributionsController do
  render_views

  let(:user) { create(:user) }
  let(:original_author) { create(:user) }
  let!(:task) { create(:task, user: original_author, access_level: 'public') }
  let(:contrib_task) { build(:task, user:, title: 'Modified title', parent_uuid: task.uuid) }
  let(:contribution) { build(:task_contribution, modifying_task: contrib_task, status: :pending) }

  before { sign_in user }

  describe 'GET #new' do
    it 'assigns a new task as @task' do
      get :new, params: {task_id: task.id}
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      subject(:post_request) { post :create, params: {task_id: task.id, task: task_params} }

      let(:task_params) { attributes_for(:task) }

      it 'creates a new Task and TaskContribution' do
        expect { post_request }
          .to change(Task, :count).by(1)
          .and change(TaskContribution, :count).by(1)
      end

      it 'assigns a newly created task as @task' do
        post_request
        expect(assigns(:task)).to be_a(Task)
        expect(assigns(:task)).to be_persisted
      end

      it 'changes required parameters' do
        post_request
        expect(assigns(:task).access_level).to eq('private')
        expect(assigns(:task).user).to eq(user)
        expect(assigns(:task).parent_uuid).to eq(task.uuid)
        expect(assigns(:task).task_contribution).not_to be_nil
        expect(assigns(:task).task_contribution.status).to eq('pending')
      end

      it 'redirects to the created task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(assigns(:task))
      end
    end
  end

  describe 'POST #approve_changes' do
    before do
      task.save!
      contribution.save!
    end

    context 'with valid params' do
      subject(:post_request) { post :approve_changes, params: {task_id: task.id, contribution_id: contribution.id} }

      it 'changes the original task, but retains certain fields' do
        post_request
        expect(assigns(:task).id).to eq(task.id)
        expect(assigns(:task).user).to eq(original_author)
        expect(assigns(:task).title).to eq('Modified title')
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
  end

  describe 'POST #discard_changes' do
    before do
      task.save!
      contribution.save!
    end

    context 'with valid params' do
      subject(:post_request) { post :discard_changes, params: {task_id: task.id, contribution_id: contribution.id} }

      it 'changes the contribution status' do
        post_request
        expect(TaskContribution.find(contribution.id).status).to eq('closed')
      end

      it 'redirects to the modified task' do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(contrib_task)
      end
    end
  end
end
