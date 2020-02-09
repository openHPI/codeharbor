# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.

  let!(:user) { FactoryBot.create(:user) }

  let(:valid_attributes) do
    FactoryBot.attributes_for(:user)
  end

  let(:invalid_attributes) do
    {email: ''}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {user_id: user.id} }

  describe 'GET #show' do
    it 'assigns the requested user as @user' do
      get :show, params: {id: user.to_param}, session: valid_session
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'GET #new' do
    it 'assigns a new user as @user' do
      get :new, params: {}, session: valid_session
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested user as @user' do
      get :edit, params: {id: user.to_param}, session: valid_session
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect do
          post :create, params: {user: valid_attributes}, session: valid_session
        end.to change(User, :count).by(1)
      end

      it 'assigns a newly created user as @user' do
        post :create, params: {user: valid_attributes}, session: valid_session
        expect(assigns(:user)).to be_a(User)
      end

      it 'persists @user' do
        post :create, params: {user: valid_attributes}, session: valid_session
        expect(assigns(:user)).to be_persisted
      end

      it 'redirects to home to wait for confirmation' do
        post :create, params: {user: valid_attributes}, session: valid_session
        expect(response).to redirect_to(home_index_path)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved user as @user' do
        post :create, params: {user: invalid_attributes}, session: valid_session
        expect(assigns(:user)).to be_a_new(User)
      end

      it 're-renders the "new" template' do
        post :create, params: {user: invalid_attributes}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { {username: 'new_name'} }

      it 'updates the requested user' do
        put :update, params: {id: user.to_param, user: new_attributes}, session: valid_session
        user.reload
        expect(user.username).to eql('new_name')
      end

      it 'assigns the requested user as @user' do
        put :update, params: {id: user.to_param, user: valid_attributes}, session: valid_session
        expect(assigns(:user)).to eq(user)
      end

      it 'redirects to the user' do
        put :update, params: {id: user.to_param, user: valid_attributes}, session: valid_session
        expect(response).to redirect_to(user)
      end
    end

    context 'with invalid params' do
      it 'assigns the user as @user' do
        put :update, params: {id: user.to_param, user: invalid_attributes}, session: valid_session
        expect(assigns(:user)).to eq(user)
      end

      it 're-renders the "edit" template' do
        put :update, params: {id: user.to_param, user: invalid_attributes}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end
end
