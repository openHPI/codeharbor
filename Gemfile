# frozen_string_literal: true

source 'https://rubygems.org'

gem 'ace-rails-ap'
# Temporary switch to a Rails 7.1 compatible fork. See https://github.com/mbleigh/acts-as-taggable-on/pull/1110
gem 'acts-as-taggable-on', github: 'aovertus/acts-as-taggable-on', branch: 'support_rails_7-1'
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'bootstrap-will_paginate'
gem 'coffee-rails', '>= 5.0.0' # Use CoffeeScript for .coffee assets and views
# Temporary switch to a Rails 7.1 compatible fork. See https://github.com/rubyconfig/config/pull/342
gem 'config', github: 'jonathanhefner/rubyconfig-config', branch: 'deep_merge-require-core-only'
gem 'devise-bootstrap-views'
gem 'faraday'
gem 'http_accept_language'
gem 'i18n-js'
gem 'image_processing'
gem 'iso-639'
gem 'jbuilder'
gem 'js-routes'
gem 'kramdown'
gem 'nested_form_fields'
gem 'net-http'
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false
gem 'nokogiri'
gem 'pg'
gem 'proformaxml', '1.0.0'
gem 'puma'
gem 'rails', '~> 7.1.1'
gem 'rails_admin', '< 4.0.0'
gem 'rails-i18n'
# Temporary switch to a Rails 7.1 compatible fork. See https://github.com/activerecord-hackery/ransack/pull/1439
gem 'ransack', github: 'yuki24/ransack', branch: 'rails-7-1'
gem 'rubyzip'
gem 'sassc-rails'
gem 'shakapacker', '7.1.0'
gem 'simple_form'
gem 'slim-rails'
gem 'sprockets-rails'
gem 'terser'
gem 'turbolinks'
gem 'whenever', require: false

# Authentication
gem 'devise', '~> 4.9'
gem 'omniauth', '~> 2.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'omniauth-saml', '~> 2.0'

# Authorization
gem 'cancancan'

# Error Tracing
gem 'mnemosyne-ruby'
gem 'stackprof' # Must be loaded before the Sentry SDK.
gem 'sentry-rails' # rubocop:disable Bundler/OrderedGems
gem 'sentry-ruby'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'listen'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack-mini-profiler'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'headless'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-github', require: false
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end
