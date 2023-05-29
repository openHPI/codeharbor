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

        expect(response.parsed_body).to have_key('results')
        expect(response.parsed_body).to have_key('pagination')
        expect(response.parsed_body['pagination']).to have_key('more')

        expect(response.parsed_body['results']).to be_an_instance_of(Array)
        expect(response.parsed_body['pagination']['more']).to be_in([true, false])
      end

      it 'returns response containing label' do
        get_request
        expect(response.parsed_body['results']).to include(a_hash_including('text' => label.name))
      end
    end
  end
end
