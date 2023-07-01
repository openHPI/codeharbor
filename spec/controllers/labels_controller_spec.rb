# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelsController do
  render_views

  let(:user) { create(:user) }
  let(:label) { create(:label) }

  describe 'GET #search' do
    subject(:get_request) { get :search, params: {search: {name_i_cont: label.name}, page: 1} }

    context 'without being signed in' do
      it 'redirects to other page' do
        get_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with valid params' do
      before { sign_in user }

      it 'returns valid json' do
        get_request
        expect(JSON.parse(response.body, symbolize_names: true)).to eql(
          {
            pagination: {more: false},
            results: [
              label.attributes.merge(
                font_color: label.font_color,
                used_by_tasks: label.tasks.count,
                created_at: label.created_at.to_fs(:rfc822), # LabelsController#search changes the time format to rfc822 before returning the labels
                updated_at: label.updated_at.to_fs(:rfc822)
              ).symbolize_keys!,
            ],
          }
        )
      end

      it 'returns response containing label' do
        get_request
        expect(response.parsed_body['results']).to include(a_hash_including('name' => label.name))
      end
    end
  end
end
