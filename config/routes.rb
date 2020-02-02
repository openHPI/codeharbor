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
    end
  end

  resources :collections do
    member do
      post :push_collection
      get :download_all
      post :share
      get :view_shared
      post :save_shared
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

  get 'groups/:id/request_access', to: 'groups#request_access', as: 'request_access'
  get 'groups/:id/confirm_request', to: 'groups#confirm_request', as: 'confirm_request'
  get 'groups/:id/grant_access', to: 'groups#grant_access', as: 'grant_access'
  get 'groups/:id/delete_from_group', to: 'groups#delete_from_group', as: 'delete_from_group'
  get 'groups/:id/make_admin', to: 'groups#make_admin', as: 'make_admin'

  get 'collections/:id/remove_exercise', to: 'collections#remove_exercise', as: 'remove_exercise_collection'
  get 'carts/:id/remove_exercise', to: 'carts#remove_exercise', as: 'remove_exercise_cart'
  get 'collections/:id/remove_all', to: 'collections#remove_all', as: 'remove_all_collection'
  get 'carts/:id/remove_all', to: 'carts#remove_all', as: 'remove_all_cart'

  post 'user/:id/messages/:id/add_author', to: 'messages#add_author', as: 'add_author'

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

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
