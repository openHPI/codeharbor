# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelsController do
  render_views

  let(:user) { create(:user) }
  let(:label) { create(:label) }

  describe 'GET #search' do
    subject(:get_request) { get :search, params: {search: label.name, page: 1} }

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
            results: [{id: label.name, label_color: label.color, label_font_color: label.font_color, text: label.name}],
          }
        )
      end

      it 'returns response containing label' do
        get_request
        expect(response.parsed_body['results']).to include(a_hash_including('text' => label.name))
      end
    end
  end
end
