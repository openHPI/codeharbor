# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exercises', type: :request do
  context 'when logged in' do
    let(:user) { FactoryBot.create(:user) }
    let(:exercise) { FactoryBot.create(:only_meta_data, authors: [user]) }
    let(:valid_params) do
      {
        title: 'title',
        descriptions_attributes: {'0' => {text: 'description'}},
        execution_environment_id: create(:java_8_execution_environment).id
      }
    end

    before do
      post login_path, params: {email: user.email, password: user.password}
      follow_redirect!
    end

    describe 'GET /exercises' do
      it 'works! (now write some real specs)' do
        get exercises_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /exercises' do
      it 'has http 302' do
        post exercises_path, params: {exercise: valid_params}
        expect(response).to have_http_status(:found)
      end
    end

    describe 'GET /exercises/new' do
      it 'has http 200' do
        get new_exercise_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /exercises/:id/edit' do
      it 'has http 200' do
        get edit_exercise_path(exercise)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /exercise/:id' do
      it 'has http 200' do
        get exercise_path(exercise)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /exercise/:id' do
      it 'has http 302' do
        patch exercise_path(exercise, exercise: valid_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'PUT /exercise/:id' do
      it 'has http 302' do
        put exercise_path(exercise, exercise: valid_params)
        expect(response).to have_http_status(:found)
      end
    end

    describe 'DELETE /exercise/:id' do
      it 'has http 302' do
        delete exercise_path(exercise)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
