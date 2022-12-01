# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks' do
  context 'when logged in' do
    let(:user) { create(:user) }
    let(:task) { create(:task, user:) }
    let(:valid_params) do
      {
        title: 'title',
        descriptions_attributes: {'0' => {text: 'description', primary: true}},
        programming_language: create(:programming_language, :ruby).id,
        license_id: create(:license).id,
        language: 'de'
      }
    end

    let(:update_params) do
      {
        title: 'new_title',
        descriptions_attributes: {'0' => {text: 'description'}},
        programming_language: create(:programming_language, :ruby).id,
        license_id: create(:license).id
      }
    end

    before do
      sign_in user
    end

    describe 'GET /tasks' do
      it 'works! (now write some real specs)' do
        get tasks_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /tasks' do
      it 'has http 302' do
        post tasks_path, params: {task: valid_params}
        expect(response).to have_http_status(:found)
      end
    end

    describe 'GET /tasks/new' do
      it 'has http 200' do
        get new_task_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /tasks/:id/edit' do
      it 'has http 200' do
        get edit_task_path(task)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /task/:id' do
      it 'has http 200' do
        get task_path(task)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /task/:id' do
      it 'has http 302' do
        patch task_path(task, task: update_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'PUT /task/:id' do
      it 'has http 302' do
        put task_path(task, task: update_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'DELETE /task/:id' do
      it 'has http 302' do
        delete task_path(task)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
