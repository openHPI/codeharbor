# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'active_storage/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Codeharbor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = ENV.fetch('RAILS_TIME_ZONE', 'UTC')

    extra_paths = %W[
      #{config.root}/lib
    ]

    config.add_autoload_paths_to_load_path = false
    config.autoload_paths += extra_paths
    config.eager_load_paths += extra_paths

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Configure asset paths
    config.assets.paths << Rails.public_path.join('assets/vendor')
    config.active_record.belongs_to_required_by_default = true

    # Specify default options for Rails generators
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end
