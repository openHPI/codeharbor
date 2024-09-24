# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController do
  render_views

  let(:user) { create(:user) }
  let(:recipient) { create(:user) }

  before do
    sign_in user
    request.headers[:referer] = user_messages_path(user)
  end

  describe 'GET #reply' do
    subject(:get_request) { get :reply, params: {user_id:, recipient:} }

    let(:user_id) { user }

    context 'when users had a conversation before' do
      let(:message) { create(:message, sender: recipient, recipient: user) }

      it 'renders the reply page' do
        message
        get_request
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when users did not a conversation before' do
      it 'does not render the reply page' do
        get_request
        expect(response).to redirect_to user_messages_path(user)
      end
    end

    context 'when not authorized to show requested user' do
      let(:user_id) { create(:user) }

      it 'redirects to user messages index' do
        expect(get_request).to redirect_to(user_messages_path(user))
      end
    end
  end

  describe 'GET #index' do
    subject(:get_request) { get :index, params: {user_id:, option:} }

    let(:user_id) { user }
    let!(:messages) { [create(:message, sender: recipient, recipient: user), create(:message, sender: user, recipient:)] }
    let(:inbox_message) { messages.first }
    let(:sent_message) { messages.second }

    context 'when indexing inbox' do
      let(:option) { 'inbox' }

      it 'marks the message as read' do
        expect { get_request }.to change { inbox_message.reload.recipient_status }.to('read')
      end

      it 'shows all messages in inbox' do
        get_request
        expect(assigns(:messages)).to contain_exactly inbox_message
      end

      context 'when not authorized to show requested user' do
        let(:user_id) { create(:user) }

        it 'redirects to user messages index' do
          expect(get_request).to redirect_to(user_messages_path(user))
        end
      end
    end

    context 'when indexing sent messages' do
      let(:option) { 'sent' }

      it 'shows all sent messages' do
        get_request
        expect(assigns(:messages)).to contain_exactly sent_message
      end

      context 'when not authorized to show requested user' do
        let(:user_id) { create(:user) }

        it 'redirects to user messages index' do
          expect(get_request).to redirect_to(user_messages_path(user))
        end
      end
    end
  end

  describe 'POST #create' do
    subject(:post_request) { post :create, params: {user_id:, message: message_params} }

    let(:user_id) { user }

    context 'with valid params' do
      let(:message_params) { {text: 'some text', recipient: recipient.email} }

      it 'redirects to user profile' do
        post_request
        expect(response).to redirect_to user_messages_path(user)
      end

      it 'creates new message' do
        expect { post_request }.to change(Message, :count).by(1)
      end

      context 'when not authorized to show requested user' do
        let(:user_id) { create(:user) }

        it 'redirects to user messages index' do
          expect(post_request).to redirect_to(user_messages_path(user))
        end
      end
    end

    context 'with invalid params' do
      let(:message_params) { {text: '', recipient: recipient.email} }

      it 'renders new template' do
        post_request
        expect(response).to render_template(:new)
      end

      it 'creates no message' do
        expect { post_request }.not_to change(Message, :count)
      end
    end
  end

  describe 'GET #new' do
    subject(:get_request) { get :new, params: {user_id:} }

    let(:user_id) { user }

    it 'assigns a new message as @message' do
      get_request
      expect(assigns(:message)).to be_a_new(Message)
    end

    context 'when not authorized to show requested user' do
      let(:user_id) { create(:user) }

      it 'redirects to user messages index' do
        expect(get_request).to redirect_to(user_messages_path(user))
      end
    end
  end

  describe 'DELETE #destroy' do
    subject(:delete_request) { delete :destroy, params: {user_id:, id: message.id} }

    let(:user_id) { user }
    let!(:message) { create(:message, sender: recipient, recipient: user, sender_status:) }
    let(:sender_status) { :sent }

    context 'when message was not deleted by sender' do
      it 'marks the message as deleted' do
        expect { delete_request }.to change { message.reload.recipient_status }.to('deleted')
      end

      it 'does not delete the message' do
        expect { delete_request }.not_to change(Message, :count)
      end
    end

    context 'when message was deleted by sender' do
      let(:sender_status) { :deleted }

      it 'deletes the message' do
        expect { delete_request }.to change(Message, :count).by(-1)
      end
    end

    context 'when not authorized to show requested user' do
      let(:user_id) { create(:user) }

      it 'redirects to user messages index' do
        expect(delete_request).to redirect_to(user_messages_path(user))
      end
    end
  end
end
