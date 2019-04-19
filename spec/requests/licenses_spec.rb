# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Licenses', type: :request do
  context 'when logged in' do
    context 'when being an admin' do
      before do
        @user = FactoryBot.create(:admin)
        post login_path, params: {email: @user.email, password: @user.password}
        follow_redirect!
      end

      describe 'GET /licenses' do
        it 'works! (now write some real specs)' do
          get licenses_path
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
