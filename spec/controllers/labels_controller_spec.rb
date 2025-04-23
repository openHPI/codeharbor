# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelsController do
  render_views

  let(:user) { create(:user) }
  let(:label) { create(:label, name: 'example label', color: 'ffffff') }
  let(:params) { {q: {name_i_cont: label.name}, page: 1} }

  before { create(:task, labels: [label]) }

  describe 'GET #search' do
    subject(:get_request) { get :search, params: }

    context 'without being signed in' do
      it 'redirects to other page' do
        get_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    shared_examples 'json without the number of referrencing tasks' do
      it 'returns valid json without tasks count' do
        get_request
        expect(JSON.parse(response.body, symbolize_names: true)).to eql(
          {
            pagination: {more: false},
            results: [{
              id: label.id,
              name: 'example label',
              color: 'ffffff',
              font_color: '000000',
              created_at: label.created_at.to_fs(:rfc822),
              updated_at: label.updated_at.to_fs(:rfc822),
            }],
          }
        )
      end
    end

    context 'when signed in as normal user' do
      before { sign_in user }

      context 'without requesting more info' do
        it_behaves_like 'json without the number of referrencing tasks'
      end

      context 'when requesting more info' do
        subject(:get_request) { get :search, params: params.merge(more_info: true) }

        it_behaves_like 'json without the number of referrencing tasks'
      end
    end

    context 'when signed in as admin' do
      let(:admin) { create(:admin) }

      before { sign_in admin }

      context 'when not requesting more info' do
        it_behaves_like 'json without the number of referrencing tasks'
      end

      context 'when requesting more info' do
        subject(:get_request) { get :search, params: params.merge(more_info: true) }

        it 'returns a valid json with more info' do
          get_request
          expect(JSON.parse(response.body, symbolize_names: true)).to eql(
            {
              pagination: {more: false},
              results: [{
                id: label.id,
                name: 'example label',
                color: 'ffffff',
                font_color: '000000',
                used_by_tasks: 1,
                created_at: label.created_at.to_fs(:rfc822),
                updated_at: label.updated_at.to_fs(:rfc822),
              }],
            }
          )
        end
      end
    end
  end

  describe 'GET #merge' do
    subject(:merge_request) { post :merge, params: {new_label_name:, label_ids: selected_labels.map(&:id)} }

    let!(:labels) { create_list(:label, 5) }
    let(:selected_labels) { labels[1..3] }
    let(:new_label_name) { 'some new name' }

    context 'without being signed in' do
      it 'redirects to another page' do
        merge_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in as admin' do
      let(:admin) { create(:admin) }

      before { sign_in admin }

      shared_examples 'error and flash message' do
        it 'returns error' do
          merge_request
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'sets flash message' do
          expect { merge_request }.to change { flash[:alert] }
        end
      end

      context 'with an invalid new label name' do
        let(:new_label_name) { '' }

        it_behaves_like 'error and flash message'
      end

      context 'with an already existing new label name' do
        let(:selected_labels) { labels[1..3] }
        let(:new_label_name) { labels.first.name }

        it_behaves_like 'error and flash message'
      end

      context 'with no labels to merge' do
        let(:selected_labels) { [] }

        it_behaves_like 'error and flash message'
      end

      context 'when the new label name is one of the selected labels except the first' do
        let(:new_label_name) { selected_labels.second.name }

        it 'renames the first label correctly' do
          expect { merge_request }.to change { selected_labels.first.reload.name }.to(new_label_name)
        end

        it 'detroys the other labels' do
          merge_request
          expect(Label.where(id: selected_labels[1..].map(&:id))).not_to exist
        end
      end
    end
  end
end
