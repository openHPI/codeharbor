# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:recipient) { create(:user) }

  before { sign_in user }

  describe 'GET #reply' do
    context 'when users had a conversation before' do
      let(:message) { create(:message, sender: recipient, recipient: user) }

      it 'renders the reply page' do
        message
        get :reply, params: {user_id: user, recipient: recipient}
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when users did not a conversation before' do
      it 'does not render the reply page' do
        get :reply, params: {user_id: user, recipient: recipient}
        expect(response).to redirect_to user_messages_path(user)
      end
    end
  end
end
