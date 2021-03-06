# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLinksController, type: :controller do
  let(:user) { create(:user) }

  let(:account_link) { create(:account_link) }

  let(:valid_attributes) { FactoryBot.attributes_for(:account_link).merge(user: user) }
  let(:invalid_attributes) do
    {api_key: ''}
  end
  let(:valid_session) do
    {user_id: user.id}
  end
  let(:invalid_session) do
    {user_id: nil}
  end
  let(:empty_params) { {user_id: user.id} }

  context 'when logged in as a User' do
    describe 'GET #new' do
      include_examples 'new examples', klass: AccountLink, resource: :account_link
    end

    describe 'GET #edit' do
      include_examples 'edit examples', klass: AccountLink, resource: :account_link
    end

    describe 'POST #create' do
      include_examples 'create examples', klass: AccountLink, resource: :account_link

      it 'with valid attributes redirects to the user' do
        post :create, params: empty_params.merge(account_link: valid_attributes), session: valid_session
        expect(response).to redirect_to(user)
      end
    end

    describe 'PUT #update' do
      let(:new_attributes) do
        attributes = FactoryBot.attributes_for(:account_link)
        attributes[:api_key] = 'secret'
        attributes
      end

      include_examples 'update examples', klass: AccountLink, resource: :account_link

      context 'with valid attributes' do
        it 'updates the requested account_link' do
          account_link = AccountLink.create! valid_attributes
          put :update, params: empty_params.merge(id: account_link.to_param, account_link: new_attributes), session: valid_session
          account_link.reload
          expect(account_link.api_key).to eq(new_attributes[:api_key])
        end

        it 'redirects to the user' do
          account_link = AccountLink.create! valid_attributes
          put :update, params: empty_params.merge(id: account_link.to_param, account_link: valid_attributes), session: valid_session
          expect(response).to redirect_to(user)
        end
      end
    end

    describe 'DELETE #destroy' do
      include_examples 'destroy examples', klass: AccountLink, resource: :account_link
      it 'with valid attributes redirects to the user' do
        account_link = AccountLink.create! valid_attributes
        delete :destroy, params: empty_params.merge(id: account_link.to_param), session: valid_session
        expect(response).to redirect_to(user)
      end
    end

    describe 'POST remove_shared_user' do
      render_views

      let(:account_link) { create(:account_link, user: user) }
      let(:shared_user) { create(:user) }

      let(:post_request) do
        post :remove_shared_user, params: {id: account_link.id, user_id: user.id, shared_user: shared_user.id}, session: valid_session
      end

      before { account_link.account_link_users << AccountLinkUser.new(user: shared_user) }

      it 'removes the account_link_user from the account_link' do
        expect { post_request }.to change(account_link.account_link_users, :count).by(-1)
      end

      it 'sets flash message' do
        expect { post_request }.to change { flash[:notice] }.to(I18n.t('controllers.account_links.removed_push', user: shared_user.email))
      end

      it 'response with correct button' do
        post_request
        expect(response.body).to include('add_shared_user')
      end
    end

    describe 'POST add_shared_user' do
      render_views

      let(:account_link) { create(:account_link, user: user) }
      let(:shared_user) { create(:user) }

      let(:post_request) do
        post :add_shared_user, params: {id: account_link.id, user_id: user.id, shared_user: shared_user.id}, session: valid_session
      end

      it 'adds the account_link_user to account_link' do
        expect { post_request }.to change(account_link.account_link_users, :count).by(1)
      end

      it 'sets flash message' do
        expect { post_request }.to change { flash[:notice] }.to(I18n.t('controllers.account_links.granted_push', user: shared_user.email))
      end

      it 'response with correct button' do
        post_request
        expect(response.body).to include('remove_shared_user')
      end

      context 'when account_link is already shared' do
        before { account_link.shared_users << shared_user }

        it 'does not add account_link_user to account_link' do
          expect { post_request }.not_to change(account_link.account_link_users, :count)
        end

        it 'sets flash message' do
          expect { post_request }.to change { flash[:alert] }.to(
            I18n.t('controllers.account_links.share_duplicate', user: shared_user.email)
          )
        end

        it 'response with correct button' do
          post_request
          expect(response.body).to include('remove_shared_user')
        end
      end
    end
  end
end
