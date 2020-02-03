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

    get 'sessions/email_link' # ???
  end

  resources :licenses # admin
  resources :execution_environments # admin

  resources :carts, only: [] do
    member do
      get :download_all
      get :remove_all # PATCH/POST?
      get :remove_exercise # PATCH/POST?

      post :push_cart # later
    end
  end

  resources :collections do
    member do
      get :download_all
      get :remove_all # PATCH/POST?
      get :remove_exercise # PATCH/POST?
      get :view_shared # ???

      post :push_collection # later
      post :save_shared # ???
      post :share
    end

    collection do
      get :collections_all # admin
    end
  end

  resources :groups do
    member do
      get :delete_from_group # PATCH/POST? User/Exercise?
      get :deny_access # POST
      get :grant_access # POST
      get :leave # POST
      get :make_admin # POST
      get :remove_exercise # POST
      get :request_access # POST

      post :add_account_link_to_member # ???
      post :remove_account_link_from_member # ???
    end

    collection do
      get :groups_all # admin
    end
  end

  controller :exercises do # import-api endpoints
    post 'import_exercise' => :import_external_exercise
    post :import_uuid_check
  end

  controller :comments do
    get 'comments/comments_all' # ???
  end

  controller :carts do
    get 'my_cart'
  end

  resources :account_links, only: :index # admin

  resources :labels do # admin
    get :search, on: :collection
  end

  resources :users do
    resources :account_links do
      post :remove_account_link, on: :member # check, test. Should remove shared accountlinks?
    end

    resources :messages, only: %i[index new create] do
      get :delete, on: :member # ? POST?
      get :reply, on: :collection
    end
  end

  resources :tests # admin

  resources :file_types do # admin
    get :search, on: :collection
  end

  resources :exercise_files, only: [] do
    get :download_attachment
  end

  resources :testing_frameworks # admin

  resources :exercises do
    member do
      get :add_author # POST
      get :contribute # POST
      get :decline_author # POST
      get :download_exercise
      get :duplicate
      get :export_external_start  # POST
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
      get :exercises_all # admin

      post :import_exercise_start
      post :import_exercise_confirm
    end

    resources :comments do # AJAX-API?
      get :load_comments, on: :collection
    end

    resources :ratings, only: :create
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
