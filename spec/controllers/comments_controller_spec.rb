# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsController do
  render_views

  let(:user) { create(:user) }
  let(:task_owner) { user }
  let(:access_level) { :private }
  let(:task) { create(:task, user: task_owner, access_level:) }

  describe 'GET #index' do
    subject(:get_request) { get :index, params: {task_id: task.id}, format: :js, xhr: true }

    shared_examples 'error redirect' do |error_message|
      it 'redirects to root page' do
        get_request
        expect(response).to have_http_status :redirect
      end

      it 'shows a flash message' do
        get_request
        expect(flash[:alert]).to eq I18n.t("common.errors.#{error_message}")
      end
    end

    shared_examples 'successful response' do
      it 'renders load_comments view' do
        get_request
        expect(response).to render_template('load_comments')
      end

      it 'answers with HTTP 200 OK' do
        get_request
        expect(response).to have_http_status :ok
      end
    end

    context 'when not signed in' do
      context 'when task access level is private' do
        it_behaves_like 'error redirect', 'not_signed_in'
      end

      context 'when task access level is public' do
        let(:access_level) { :public }

        it_behaves_like 'successful response'
      end
    end

    context 'when signed in' do
      before { sign_in user }

      context 'when user is owner of task' do
        it_behaves_like 'successful response'
      end

      context 'when user is not owner of task' do
        let(:task_owner) { create(:user) }

        context 'when task is public' do
          let(:access_level) { :public }

          it_behaves_like 'successful response'
        end

        context 'when task is private' do
          it_behaves_like 'error redirect', 'not_authorized'
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:access_level) { :public }
    let(:comment) { create(:comment, user:, task:) }

    before { sign_in user }

    it 'answers with HTTP 200 OK' do
      get :edit, params: {task_id: task.id, id: comment.id}, format: :js, xhr: true
      expect(response).to have_http_status :ok
    end
  end
end
