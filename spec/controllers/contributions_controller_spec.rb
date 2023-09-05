# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContributionsController do
  render_views

  let(:user) { create(:user) }
  let(:original_author) { create(:user) }
  let(:task) { create(:task, user: original_author) }

  before { sign_in user }
  describe 'GET #new' do
    it 'assigns a new task as @task' do
      get :new, params: { task_id: task.id }
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      subject(:request) { post :create, params: { task_id: task.id, task: task_params } }
      let(:task_params) { attributes_for(:task) }

      it 'creates a new Task' do
        expect { request }.to change(Task, :count).by(1)
        expect { request }.to change(TaskContribution, :count).by(1)
      end

      it 'assigns a newly created task as @task' do
        request
        expect(assigns(:task)).to be_a(Task)
        expect(assigns(:task)).to be_persisted
      end

      it 'changes required parameters' do
        request
        expect(assigns(:task).access_level).to eq('private')
        expect(assigns(:task).user).to eq(user)
        expect(assigns(:task).parent_uuid).to eq(task.uuid)
        expect(assigns(:task).task_contribution).not_to be_nil
        expect(assigns(:task).task_contribution.status).to eq('pending')
      end

      it 'redirects to the created task' do
        request
        expect(response).to redirect_to(Task.find(assigns(:task).id))
      end
    end
  end
end
