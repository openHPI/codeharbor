# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'shakapacker'
require 'sprockets/railtie'
require_relative '../lib/shakapacker/sri_helper_extensions'
require_relative '../lib/shakapacker/sri_manifest_extensions'
require_relative '../lib/middleware/edu_sharing_content_type'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CodeHarbor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = ENV.fetch('RAILS_TIME_ZONE', 'UTC')

    extra_paths = [
      Rails.root.join('lib'),
    ]

    config.add_autoload_paths_to_load_path = false
    config.autoload_paths += extra_paths
    config.eager_load_paths += extra_paths

    config.relative_url_root = ENV.fetch('RAILS_RELATIVE_URL_ROOT', '/').to_s

    # Specify default options for Rails generators
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    # Fix invalid Content-Type header for incoming requests made by edu-sharing.
    config.middleware.insert_before 0, Middleware::EduSharingContentType
  end
end
