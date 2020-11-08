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

  def get_default_columns(model)
    RailsAdmin::Config::Fields.factory(model).map { |i| {i.name.to_sym => i.class} }
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

  config.model 'Cart' do
    add_valid_column(self)
  end

  config.model 'Collection' do
    add_valid_column(self)
  end

  config.model 'Comment' do
    add_valid_column(self)
  end

  config.model 'Description' do
    add_valid_column(self)
  end

  config.model 'ExecutionEnvironment' do
    add_valid_column(self)
  end

  config.model 'Exercise' do
    add_valid_column(self)
  end

  config.model 'ExerciseAuthor' do
    add_valid_column(self)
  end

  config.model 'ExerciseFile' do
    add_valid_column(self)
  end

  config.model 'ExerciseRelation' do
    add_valid_column(self)
  end

  config.model 'FileType' do
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

  config.model 'Rating' do
    add_valid_column(self)
  end

  config.model 'Relation' do
    add_valid_column(self)
  end

  config.model 'Report' do
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
end
