# frozen_string_literal: true

source 'https://rubygems.org'

gem 'i18n-js', '< 4.0.0' # Newer versions require the npm package `i18n-js`
gem 'js-routes'
# Create Zip files
gem 'rubyzip'
# Private Data
gem 'figaro'
# Translate
gem 'i18n'
gem 'iso-639'
# Use slim format
gem 'slim-rails', '>= 3.2.0'
# Rails
gem 'rails', '~> 7.0'
gem 'sprockets-rails'
# Use postgres as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6.0.0'
# Use Terser as compressor for JavaScript assets
gem 'terser'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '>= 5.0.0'

# Use puma instead of WEBrick
gem 'puma'
# Use simple_form
gem 'simple_form', '>= 5.0.1'
# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.3.5'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.19'

# Pagination
gem 'will_paginate'

# Authentication
gem 'devise', '~> 4.9'
gem 'omniauth', '~> 2.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'omniauth-saml', '~> 2.0'

# Authorization
gem 'cancancan'

# Use Bootstrap (app/assets/stylesheets)
gem 'devise-bootstrap-views', '~> 1.0'
gem 'twitter-bootstrap-rails'

gem 'ace-rails-ap'
gem 'acts-as-taggable-on', '~> 9.0'
gem 'config'
gem 'faraday'
gem 'font-awesome-rails', '>= 4.7.0.5'
gem 'image_processing'
gem 'jquery-ui-rails', '>= 6.0.1'
gem 'kramdown', '~> 2.4'
gem 'nested_form_fields', '>= 0.8.2'
gem 'net-http', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false
gem 'nokogiri'
gem 'proforma', git: 'https://github.com/openHPI/proforma.git', tag: 'v0.8'
gem 'rails_admin', '~> 3.1'
gem 'ransack'
gem 'select2-rails', '~> 4.0'
gem 'sprockets', '~> 4.2.0'

# Error Tracing
gem 'concurrent-ruby'
gem 'mnemosyne-ruby'
gem 'stackprof' # Must be loaded before the Sentry SDK.
gem 'sentry-rails' # rubocop:disable Bundler/OrderedGems
gem 'sentry-ruby'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'rails-controller-testing', '>= 1.0.4'
  gem 'rspec-collection_matchers', '~> 1.2.0'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rack-mini-profiler'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 3.7.0'

  gem 'letter_opener'

  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'headless'
  gem 'rspec-github', require: false
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'webmock'
end
gem 'sassc-rails'
