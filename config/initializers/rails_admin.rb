# frozen_string_literal: true

RailsAdmin.config do |config|
  config.asset_source = :webpacker
  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  config.authorize_with do
    # Important! We need to check the authorization here, we skip pundit checks in the RailsAdminController.
    unless current_user&.role == 'admin'
      flash[:alert] = t('common.errors.not_authorized')
      redirect_to main_app.root_path
    end
  end

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.parent_controller = '::RailsAdminController'
  config.excluded_models = %w[OmniAuth::Strategies::Bird OmniAuth::Strategies::Nbp]

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  config.show_gravatar = false

  def get_default_columns(model)
    RailsAdmin::Config::Fields.factory(model).map {|i| {i.name.to_sym => i.class} }
  end

  def add_valid_column(model)
    columns = get_default_columns(model)
    columns.insert(1, {valid?: RailsAdmin::Config::Fields::Types::Boolean})

    list do
      columns.each do |hash|
        key = hash.keys.first
        field(key, hash[key].to_s.demodulize.underscore)
      end
    end
  end

  config.model 'AccountLink' do
    add_valid_column(self)
  end

  config.model 'AccountLinkUser' do
    add_valid_column(self)
  end

  config.model 'Collection' do
    add_valid_column(self)
  end

  config.model 'Comment' do
    add_valid_column(self)
  end

  config.model 'Group' do
    add_valid_column(self)
  end

  config.model 'GroupMembership' do
    add_valid_column(self)
  end

  config.model 'ImportFileCache' do
    add_valid_column(self)
  end

  config.model 'Label' do
    add_valid_column(self)
  end

  config.model 'License' do
    add_valid_column(self)
  end

  config.model 'Message' do
    add_valid_column(self)
  end

  config.model 'ModelSolution' do
    add_valid_column(self)
  end

  config.model 'ProgrammingLanguage' do
    add_valid_column(self)
  end

  config.model 'Rating' do
    add_valid_column(self)
  end

  config.model 'Relation' do
    add_valid_column(self)
  end

  config.model 'Task' do
    add_valid_column(self)
  end

  config.model 'TaskFile' do
    add_valid_column(self)
  end

  config.model 'TaskLabel' do
    add_valid_column(self)
  end

  config.model 'Test' do
    add_valid_column(self)
  end

  config.model 'TestingFramework' do
    add_valid_column(self)
  end

  config.model 'User' do
    add_valid_column(self)
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

  # stolen from https://github.com/kaminari/kaminari/issues/162#issuecomment-52083985
  if defined?(WillPaginate)
    module WillPaginate
      module ActiveRecord
        module RelationMethods
          def per(value = nil)
            per_page(value)
          end

          def total_count
            count
          end

          def first_page?
            self == first
          end

          def last_page?
            self == last
          end
        end
      end

      module CollectionMethods
        alias num_pages total_pages
      end
    end
  end
end
