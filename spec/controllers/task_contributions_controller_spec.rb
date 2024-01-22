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
    subject(:post_request) { post :create, params: {task_id: task.id, task: task_params} }

    let(:task_params) { attributes_for(:task) }

    context 'with valid params' do
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
    before do
      task.save!
      contribution.save!
    end

    context 'with valid params' do
      subject(:post_request) { post :approve_changes, params: {task_id: task.id, id: contribution.id} }

      it 'changes the original task, but retains certain fields' do
        post_request
        # check that :task was assigned id 1
        expect(assigns(:task).id).to eq(1)


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
        expect(response).to redirect_to(contrib_task)
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
        expect(response).to redirect_to(contrib_task)
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
        expect(response).to redirect_to(contrib_task)
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
      it 'redirects to the associated task' do
        get_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(contrib_task)
      end
    end
  end
end
