# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelsController do
  render_views

  let(:user) { create(:user) }
  let(:label) { create(:label) }

  describe 'GET #search' do
    context 'without being signed in' do
      it 'redirects to other page' do
        get :search, params: {search: label.name, page: 1}
        expect(response.body).to match(%r{^<html><body>You are being.*redirected.*</body></html>$})
      end
    end

    context 'with valid params' do
      subject(:request) { get :search, params: {search: label.name, page: 1} }

      before { sign_in user }

      it 'returns valid json' do
        request
        expect(response.body).to match(/^{"results":\[.*\],"pagination":{"more":(true|false)}}$/)
      end

      it 'returns response containing label' do
        request
        expect(response.body).to include(label.name)
      end
    end
  end
end
