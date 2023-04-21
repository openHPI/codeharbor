# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsController do
  render_views

  let(:user) { create(:user) }
  let(:task) { create(:task) }

  before { sign_in user }

  describe 'GET #index' do
    it 'renders load_comments view' do
      get :index, params: {task_id: task.id}, format: :js, xhr: true
      expect(response).to render_template('load_comments')
    end

    it 'answers with HTTP 200 OK' do
      get :index, params: {task_id: task.id}, format: :js, xhr: true
      expect(response).to have_http_status :ok
    end
  end

  describe 'GET #edit' do
    it 'answers with HTTP 200 OK' do
      get :index, params: {task_id: task.id}, format: :js, xhr: true
      expect(response).to have_http_status :ok
    end
  end
end
