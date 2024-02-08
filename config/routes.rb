# frozen_string_literal: true

Rails.application.routes.draw do
  # You can have the root of your site routed with "root"
  root to: 'home#index'

  resources :home, only: :index do
    collection do
      get :about
      get :account_link_documentation
    end
  end

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks',
  }

  devise_scope :user do
    delete '/users/deauth/:provider' => 'users/omniauth_callbacks#deauthorize', as: :omniauth_deauthorize
  end

  resources :users, only: %i[show] do
    resources :account_links, only: %i[new show create edit update destroy] do
      post :remove_shared_user, on: :member
      post :add_shared_user, on: :member
    end

    resources :messages, only: %i[index new create destroy] do
      get :reply, on: :collection
    end

    collection do
      get '/nbp_wallet/connect', to: 'users/nbp_wallet#connect'
      get '/nbp_wallet/qr_code', to: 'users/nbp_wallet#qr_code'
      get '/nbp_wallet/relationship_status', to: 'users/nbp_wallet#relationship_status'
      get '/nbp_wallet/finalize', to: 'users/nbp_wallet#finalize'
    end
  end

  resources :collections do
    member do
      get :download_all
      get :view_shared # ???

      patch :remove_all
      patch :remove_task

      post :push_collection # later
      post :save_shared # ???
      post :share
      post :leave

      post :toggle_favorite
    end
  end

  resources :groups do
    member do
      post :deny_access
      post :grant_access
      post :leave
      post :make_admin
      post :demote_admin
      post :request_access

      patch :delete_from_group
      patch :remove_task
    end
  end

  resources :labels, only: %i[index update destroy] do
    collection do
      get :search
      post :merge
    end
  end

  resources :task_files, only: [] do
    member do
      get :download_attachment
      get :extract_text_data
    end
  end

  resources :tasks do
    member do
      get :download
      post :export_external_start
      post :export_external_check
      post :export_external_confirm
      post :add_to_collection
      post :duplicate
      post :generate_test
    end

    collection do
      post :import_start
      post :import_confirm
    end
    resources :comments, only: %i[index edit create update destroy]
    resources :ratings, only: :create

    resources :task_contributions, only: %i[show new create edit update] do
      member do
        post :approve_changes
        post :discard_changes
      end
    end
  end

  controller :tasks do # import-api endpoints
    post :import_task, action: :import_external, defaults: {format: :json}
    post :import_uuid_check, defaults: {format: :json}
  end

  scope 'bridges', module: :bridges, as: 'bridges' do
    scope 'lom', module: :lom, as: 'lom' do
      resources :tasks, only: %i[show]
    end
    scope 'bird', module: :bird, as: 'bird' do
      resources :tasks, only: %i[index]
    end
    scope module: :oai do
      match :oai, to: 'oai#handle_request', via: %i[get post]
    end
  end

  resources :ping, only: :index, defaults: {format: :json}

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
