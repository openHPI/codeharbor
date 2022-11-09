# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskFilesController do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET #download_attachment' do
    subject(:get_request) { get :download_attachment, params: params }

    let!(:task_file) { create(:task_file, :with_task, :with_attachment, fileable: build(:task, user: task_user)) }
    let(:params) { {id: task_file.id} }
    let(:task_user) { user }

    it 'redirects to the file download' do
      get_request
      expect(response).to redirect_to rails_blob_path(task_file.attachment, disposition: 'attachment')
    end

    context 'when user is not authorized' do
      let(:task_user) { build(:user) }

      it 'redirects to the root_path' do
        get_request
        expect(response).to redirect_to root_path
      end
    end
  end
end
