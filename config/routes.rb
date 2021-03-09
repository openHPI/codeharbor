# frozen_string_literal: true

Rails.application.routes.draw do
  # You can have the root of your site routed with "root"
  root 'home#index'
  resources :home, only: :index do
    collection do
      get :about
      get :account_link_documentation
      get :confirm_email
      get :forgot_password
      get :resend_confirmation
      get :reset_password
    end
  end

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy

    get 'sessions/email_link'
  end

  resources :collections do
    member do
      get :download_all
      get :view_shared # ???

      patch :remove_all
      patch :remove_exercise

      post :push_collection # later
      post :save_shared # ???
      post :share
      post :leave
    end
  end

  resources :groups do
    member do
      post :deny_access
      post :grant_access
      post :leave
      post :make_admin
      post :request_access

      patch :delete_from_group
      patch :remove_exercise
    end
  end

  resources :labels, only: [] do
    get :search, on: :collection
  end

  resources :users, only: %i[new show create edit update destroy] do
    resources :account_links, only: %i[new show create edit update destroy] do
      post :remove_shared_user, on: :member
      post :add_shared_user, on: :member
    end

    resources :messages, only: %i[index new create destroy] do
      get :reply, on: :collection
    end
  end

  resources :file_types, only: [] do
    get :search, on: :collection
  end

  resources :task_files, only: [] do
    member do
      get :download_attachment
    end
  end

  resources :tasks

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
