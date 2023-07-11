# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelsController do
  render_views

  let(:user) { create(:user) }
  let(:label) { create(:label, name: 'example label', color: 'ffffff') }
  let(:params) { {search: {name_i_cont: label.name}, page: 1} }

  before { create(:task, labels: [label]) }

  describe 'GET #search' do
    subject(:get_request) { get :search, params: }

    context 'without being signed in' do
      it 'redirects to other page' do
        get_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_url)
      end
    end

    shared_examples 'json without tasks count' do
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
              used_by_tasks: 0,
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
        include_examples 'json without tasks count'
      end

      context 'when requesting more info' do
        subject(:get_request) { get :search, params: params.merge(more_info: true) }

        include_examples 'json without tasks count'
      end
    end

    context 'when signed in as admin' do
      let(:admin) { create(:admin) }

      before { sign_in admin }

      context 'when not requesting more info' do
        include_examples 'json without tasks count'
      end

      context 'when requesting more info' do
        subject(:get_request) { get :search, params: params.merge(more_info: true) }

        it 'returns valid json with more info' do
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
    subject(:merge_request) { get :merge, params: {label_ids:, new_name:} }

    let!(:labels) { create_list(:label, 5) }
    let(:label_ids) { labels[1..3].map(&:id) }
    let(:new_name) { 'some new name' }

    context 'without being signed in' do
      it 'redirects to other page' do
        merge_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when signed in as admin' do
      let(:admin) { create(:admin) }

      before { sign_in admin }

      context 'with invalid new label name' do
        let(:new_name) { '' }

        it 'returns error' do
          merge_request
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'with no labels to merge' do
        let(:label_ids) { [] }

        it 'returns error' do
          merge_request
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
