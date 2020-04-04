# frozen_string_literal: true

RailsAdmin.config do |config|
  ### Popular gems integration

  # == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  config.parent_controller = 'ApplicationController'
  config.current_user_method(&:current_user)
  # == CancanCan ==
  # config.authorize_with :cancancan
  config.authorize_with do
    unless can?(:access, :rails_admin)
      flash[:alert] = 'Access denied.'
      redirect_to main_app.root_path
    end
  end

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.model AccountLink do
    list do
      field :id
      field :user
      field :name
      field :valid?, :boolean
      field :created_at
      field :updated_at

      field :push_url
      field :check_uuid_url
      field :account_link_users
      field :shared_users
      field :api_key
    end
  end

  config.model Cart do
    list do
      field :id
      field :user
      field :exercises
      field :valid?, :boolean
      field :created_at
      field :updated_at

      field :cart_exercises
    end
  end

  config.model Collection do
    list do
      field :id
      field :title
      field :users
      field :valid?, :boolean
      field :created_at
      field :updated_at

      field :collection_users
      field :exercises
      field :collection_exercises
    end
  end

  config.model Comment do
    list do
      field :id
      field :text
      field :exercise
      field :valid?, :boolean
      field :created_at
      field :updated_at

      field :user
    end
  end
  config.model Description do
    list do
      field :id
      field :text
      field :exercise
      field :valid?, :boolean
      field :created_at
      field :updated_at

      field :language
      field :primary?
    end
  end

  config.model Exercise do
    list do
      field :id
      field :title
      field :instruction
      field :private?, :boolean
      field :valid?, :boolean
      field :created_at

      field :deleted, :boolean
      field :downloads
      field :user
      field :descriptions
      field :execution_environment
      field :updated_at

      field :exercise_files
      field :tests
      field :uuid
      field :predecessor
      field :successor
      field :license

      field :groups
      field :group_memberships_as_member
      field :labels
      field :exercise_labels
      field :comments
      field :ratings

      field :authors
      field :exercise_authors
      field :collections
      field :collection_exercises
      field :carts
      field :cart_exercises

      field :reports
      field :maxrating
      field :origin_relations
      field :clone_relations
    end
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
