# frozen_string_literal: true

Rails.application.routes.draw do
  # You can have the root of your site routed with "root"
  root 'home#index'
  resources :home, only: :index do
    collection do
      get :reset_password
      get :confirm_email
      get :forgot_password
      get :resend_confirmation
      get :about
      get :account_link_documentation
    end
  end

  resources :licenses # admin
  resources :execution_environments # admin

  resources :carts, only: [] do
    member do
      get :download_all
      post :push_cart
      get :remove_exercise
      get :remove_all
    end
  end

  resources :collections do
    member do
      post :push_collection
      get :download_all
      post :share
      get :view_shared
      post :save_shared
      get :remove_exercise
      get :remove_all
    end

    collection do
      get :collections_all # admin
    end
  end

  resources :groups do
    member do
      get :remove_exercise
      get :leave
      get :deny_access
      get :request_access
      get :grant_access
      get :delete_from_group
      get :make_admin

      post :add_account_link_to_member # ???
      post :remove_account_link_from_member # ???
    end

    collection do
      get :groups_all # admin
    end
  end

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
    get 'sessions/email_link'
  end

  controller :exercises do # import-api endpoints
    post 'import_exercise' => 'import_external_exercise'
    post 'import_uuid_check'
  end

  controller :comments do
    get 'comments/comments_all'
  end

  controller :carts do
    get 'my_cart'
  end

  ##########


  get 'exercise_files/:id/download_attachment', to: 'exercise_files#download_attachment', as: 'download_attachment'

  post 'passwords/forgot', to: 'passwords#forgot'
  post 'passwords/reset', to: 'passwords#reset'

  get 'account_links' => 'account_links#index' # admin

  resources :labels do # admin
    get :search, on: :collection
  end

  resources :users do
    resources :account_links do
      post :remove_account_link, on: :member
    end

    resources :messages, only: %i[index new create] do
      get :delete, on: :member
      get :reply, on: :collection
    end
  end

  resources :tests

  resources :file_types do
    get :search, on: :collection
  end

  resources :exercise_files
  resources :testing_frameworks

  resources :exercises do
    member do
      get :duplicate, as: 'duplicate'
      post :add_to_cart
      post :add_to_collection
    end

    collection do
      get :add_label
      post :import_exercise_start
      post :import_exercise_confirm
      get :exercises_all # admin
    end

    resources :comments do
      collection do
        get :load_comments
      end
    end

    resources :ratings, only: :create
    member do
      get :related_exercises
      post :report
      get :add_author
      get :decline_author
      get :contribute
      get :download_exercise
      post :remove_state
      get :history
      get :export_external_start
      post :export_external_check
      post :export_external_confirm
    end
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
