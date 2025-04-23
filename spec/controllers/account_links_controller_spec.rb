# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLinksController do
  render_views

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  let(:account_link) { create(:account_link, user:) }
  let(:account_link_from_another_user) { create(:account_link, user: another_user) }

  let(:valid_attributes) { attributes_for(:account_link) }
  let(:invalid_attributes) do
    {api_key: ''}
  end
  let(:empty_params) { {user_id: user.id} }

  context 'when logged in as a User' do
    before { sign_in user }

    describe 'GET #show' do
      it 'works with a valid account link' do
        get :show, params: {id: account_link.id, user_id: user.id}
        expect(response).to have_http_status :ok
      end

      it 'does not show an internal server error on Pundit::NotAuthorizedError' do
        get :show, params: {id: account_link_from_another_user.id, user_id: another_user.id}
        expect(response).not_to have_http_status :internal_server_error
      end

      it 'does not show an internal server error on ActiveRecord::RecordNotFound' do
        get :show, params: {id: 987_654_321, user_id: another_user.id}
        expect(response).not_to have_http_status :internal_server_error
      end
    end

    describe 'GET #new' do
      it_behaves_like 'new examples', klass: AccountLink, resource: :account_link
    end

    describe 'GET #edit' do
      it_behaves_like 'edit examples', klass: AccountLink, resource: :account_link
    end

    describe 'POST #create' do
      it_behaves_like 'create examples', klass: AccountLink, resource: :account_link

      it 'with valid attributes redirects to the user' do
        post :create, params: empty_params.merge(account_link: valid_attributes)
        expect(response).to redirect_to(user)
      end
    end

    describe 'PUT #update' do
      let(:new_attributes) do
        attributes = attributes_for(:account_link)
        attributes[:api_key] = 'secret'
        attributes
      end

      it_behaves_like 'update examples', klass: AccountLink, resource: :account_link

      context 'with valid attributes' do
        it 'updates the requested account_link' do
          account_link = AccountLink.create! valid_attributes.merge(user:)
          put :update, params: empty_params.merge(id: account_link.to_param, account_link: new_attributes)
          account_link.reload
          expect(account_link.api_key).to eq(new_attributes[:api_key])
        end

        it 'redirects to the user' do
          account_link = AccountLink.create! valid_attributes.merge(user:)
          put :update, params: empty_params.merge(id: account_link.to_param, account_link: valid_attributes)
          expect(response).to redirect_to(user)
        end
      end
    end

    describe 'DELETE #destroy' do
      it_behaves_like 'destroy examples', klass: AccountLink, resource: :account_link
      it 'with valid attributes redirects to the user' do
        account_link = AccountLink.create! valid_attributes.merge(user:)
        delete :destroy, params: empty_params.merge(id: account_link.to_param)
        expect(response).to redirect_to(user)
      end
    end

    describe 'POST remove_shared_user' do
      render_views

      let(:account_link) { create(:account_link, user:) }
      let(:shared_user) { create(:user) }

      let(:post_request) do
        post :remove_shared_user, params: {id: account_link.id, user_id: user.id, shared_user: shared_user.id}
      end

      before { account_link.account_link_users << AccountLinkUser.new(user: shared_user) }

      it 'removes the account_link_user from the account_link' do
        expect { post_request }.to change(account_link.account_link_users, :count).by(-1)
      end

      it 'sets flash message' do
        expect { post_request }.to change { flash[:notice] }.to(I18n.t('account_links.remove_shared_user.removed_push', user: shared_user.email))
      end

      it 'response with correct button' do
        post_request
        expect(response.body).to include('add_shared_user')
      end
    end

    describe 'POST add_shared_user' do
      render_views

      let(:account_link) { create(:account_link, user:) }
      let(:shared_user) { create(:user) }

      let(:post_request) do
        post :add_shared_user, params: {id: account_link.id, user_id: user.id, shared_user: shared_user.id}
      end

      it 'adds the account_link_user to account_link' do
        expect { post_request }.to change(account_link.account_link_users, :count).by(1)
      end

      it 'sets flash message' do
        expect { post_request }.to change { flash[:notice] }.to(I18n.t('account_links.add_shared_user.granted_push', user: shared_user.email))
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
            I18n.t('account_links.add_shared_user.share_duplicate', user: shared_user.email)
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
