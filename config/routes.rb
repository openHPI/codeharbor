Rails.application.routes.draw do



  resources :relations
  resources :exercise_relations
  # You can have the root of your site routed with "root"
  root 'home#index'
  
  resources :execution_environments
  resources :carts do
    member do
      get :download_all
    end
  end
  resources :collections do
    member do
      get :download_all
    end
  end
  resources :groups do
    get :search, :on => :collection
    member do
      get :remove_exercise
    end
  end
  get 'home/index'

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  get 'sessions/create'
  get 'sessions/destroy'

  get 'comments/comments_all'
  get 'exercises/exercises_all'

  get 'my_cart', to: 'carts#my_cart', as: 'my_cart'

  get 'exercises/:id/duplicate', to: 'exercises#duplicate', as: 'duplicate_exercise'
  post 'exercises/:id/add_to_cart', to: 'exercises#add_to_cart', as: 'add_to_cart'
  post 'exercises/:id/add_to_collection', to: 'exercises#add_to_collection', as: 'add_to_collection'
  get 'labels/autocomplete' => 'labels#autocomplete'

  get 'groups/:id/request_access', to: 'groups#request_access', as: 'request_access'
  get 'groups/:id/confirm_request', to: 'groups#confirm_request', as: 'confirm_request'
  get 'groups/:id/grant_access', to: 'groups#grant_access', as: 'grant_access'
  get 'groups/:id/delete_from_group', to: 'groups#delete_from_group', as: 'delete_from_group'
  get 'groups/:id/make_admin', to: 'groups#make_admin', as: 'make_admin'

  get 'collections/:id/remove_exercise', to: 'collections#remove_exercise' ,as: 'remove_exercise_collection'
  get 'carts/:id/remove_exercise', to: 'carts#remove_exercise' ,as: 'remove_exercise_cart'
  get 'collections/:id/remove_all', to: 'collections#remove_all' ,as: 'remove_all_collection'
  get 'carts/:id/remove_all', to: 'carts#remove_all' ,as: 'remove_all_cart'

  post 'user/:id/messages/:id/add_author', to: 'messages#add_author', as: 'add_author'


  resources :labels do
    get :search, :on => :collection
  end
  resources :label_categories
  resources :users do
    resources :account_links
    resources :messages
  end
  resources :tests
  resources :file_types do
    get :search, :on => :collection
  end
  resources :exercise_files
  resources :testing_frameworks
  resources :exercises do
    collection do
      get :add_label
      post :import_exercise
    end
    resources :comments do
      resources :answers
      collection do
        get :load_comments
      end
    end
    resources :ratings
    member do
      post :push_external
      get :contribute
      get :download_exercise
    end
  end




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
