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

  config.model AccountLinkUser do
    list do
      field :id
      field :user
      field :account_link
      field :valid?, :boolean
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

  config.model ExecutionEnvironment do
    list do
      field :id
      field :language
      field :version
      field :valid?, :boolean
      field :created_at
      field :updated_at
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

  config.model ExerciseAuthor do
    list do
      field :id
      field :exercise
      field :user
      field :valid?, :boolean
      field :created_at
      field :updated_at
    end
  end

  config.model ExerciseFile do
    list do
      field :id
      field :content
      field :path
      field :name
      field :valid?, :boolean
      field :created_at

      field :solution, :boolean
      field :visibility, :boolean
      field :hidden, :boolean
      field :exercise
      field :role
      field :updated_at

      field :read_only, :boolean
      field :file_type
      field :attachment
      field :exercise_test
      field :purpose
    end
  end

  config.model ExerciseRelation do
    list do
      field :id
      field :origin
      field :clone
      field :valid?, :boolean
      field :updated_at
      field :created_at

      field :relation
    end
  end

  config.model FileType do
    list do
      field :id
      field :name
      field :editor_mode
      field :valid?, :boolean
      field :updated_at
      field :created_at

      field :file_extension
      field :exercise_files
    end
  end

  config.model Group do
    list do
      field :id
      field :name
      field :description
      field :valid?, :boolean
      field :updated_at
      field :created_at

      field :group_memberships_as_group
      field :users
      field :members
      field :exercises
    end
  end

  config.model GroupMembership do
    list do
      field :id
      field :member
      field :group
      field :valid?, :boolean
      field :updated_at
      field :created_at

      field :group_name
      field :membership_type
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
