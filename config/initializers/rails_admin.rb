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

  config.model ImportFileCache do
    list do
      field :id
      field :user
      field :data
      field :valid?, :boolean
      field :updated_at
      field :created_at

      field :zip_file
    end
  end

  config.model Label do
    list do
      field :id
      field :name
      field :color
      field :valid?, :boolean
      field :updated_at
      field :created_at

      field :exercise_labels
      field :exercises
    end
  end

  config.model License do
    list do
      field :id
      field :name
      field :link
      field :valid?, :boolean
      field :updated_at
      field :created_at
    end
  end

  config.model Message do
    list do
      field :id
      field :text
      field :sender
      field :recipient
      field :valid?, :boolean
      field :created_at

      field :param_type
      field :param_id
      field :sender_status
      field :recipient_status
      field :updated_at
    end
  end

  config.model Rating do
    list do
      field :id
      field :rating
      field :exercise
      field :user
      field :valid?, :boolean
      field :created_at

      field :updated_at
    end
  end

  config.model Relation do
    list do
      field :id
      field :name
      field :exercise_relations
      field :valid?, :boolean
      field :created_at
      field :updated_at
    end
  end

  config.model Report do
    list do
      field :id
      field :exercise
      field :user
      field :text
      field :valid?, :boolean
      field :created_at

      field :updated_at
    end
  end

  config.model Test do
    list do
      field :id
      field :feedback_message
      field :testing_framework
      field :exercise
      field :valid?, :boolean
      field :created_at

      field :score
      field :exercise_file
      field :updated_at
    end
  end

  config.model TestingFramework do
    list do
      field :id
      field :name
      field :version
      field :tests
      field :valid?, :boolean
      field :created_at

      field :updated_at
    end
  end

  config.model User do
    list do
      field :id
      field :first_name
      field :last_name
      field :email
      field :valid?, :boolean
      field :created_at

      field :role
      field :deleted, :boolean
      field :avatar
      field :username
      field :description
      field :updated_at

      field :email_confirmed
      field :confirm_token
      field :reset_password_token
      field :reset_password_sent_at
      field :group_memberships_as_member
      field :groups

      field :collection_users
      field :collections
      field :account_link_users
      field :shared_account_links
      field :reports
      field :account_links

      field :password_digest
      field :exercises
      field :cart
      field :exercise_authors
      field :authored_exercises
      field :sent_messages

      field :received_messages
    end
  end

  # config.model UserGroup do
  #   list do
  #     field :id
  #     field :is_admin
  #     field :is_active
  #     field :user
  #     field :valid?, :boolean
  #     field :created_at

  #     field :updated_at
  #   end
  # end

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
