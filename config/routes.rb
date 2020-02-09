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

  resources :carts, only: [] do
    member do
      get :download_all

      patch :remove_all
      patch :remove_exercise

      post :push_cart # later
    end
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

      post :add_account_link_to_member # ???
      post :remove_account_link_from_member # ???
    end
  end

  controller :exercises do # import-api endpoints
    post 'import_exercise' => :import_external_exercise
    post :import_uuid_check
  end

  controller :carts do
    get 'my_cart'
  end

  resources :labels, only: [] do
    get :search, on: :collection
  end

  resources :users, only: %i[new show create edit update destroy] do
    resources :account_links, only: %i[new create edit update destroy] do
      post :remove_account_link, on: :member # check, test. Should remove shared accountlinks?
    end

    resources :messages, only: %i[index new create destroy] do
      # get :delete, on: :member # ? POST?
      get :reply, on: :collection
    end
  end

  resources :file_types, only: [] do
    get :search, on: :collection
  end

  resources :exercise_files, only: [] do
    get :download_attachment
  end

  resources :exercises do
    member do
      get :add_author # POST
      get :contribute # POST
      get :decline_author # POST
      get :download_exercise
      get :duplicate
      get :export_external_start # POST
      get :history
      get :related_exercises

      post :add_to_cart
      post :add_to_collection
      post :export_external_check
      post :export_external_confirm
      post :remove_state
      post :report
    end

    collection do
      post :import_exercise_start
      post :import_exercise_confirm
    end

    resources :comments # AJAX-API

    resources :ratings, only: :create
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
