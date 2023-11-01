# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskFilesController do
  render_views

  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET #download_attachment' do
    subject(:get_request) { get :download_attachment, params: }

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

  describe 'GET #extract_text_data' do
    subject(:get_request) { get :extract_text_data, params: }

    let(:task_file) { create(:task_file, :with_task, :with_text_attachment, fileable: build(:task, user: task_user)) }
    let(:params) { {id: task_file.id} }
    let(:task_user) { user }

    it 'returns content of the file' do
      get_request
      expect(response.body).to eql '{"text_data":"beipsieltext\n"}'
    end

    context 'when attachment does not contain text' do
      let(:task_file) { create(:task_file, :with_task, :with_attachment, fileable: build(:task, user: task_user)) }

      it 'returns content of the file' do
        get_request
        expect(response.body).to eql "{\"error\":\"#{I18n.t('task_files.extract_text_data.no_text')}\"}"
      end
    end
  end
end
