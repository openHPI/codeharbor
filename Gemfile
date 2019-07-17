# frozen_string_literal: true

source 'https://rubygems.org'

gem 'proforma', path: '../proforma'
# Handle file upload
gem 'paperclip'
# Create Zip files
gem 'rubyzip'
# Handle Group Access
gem 'groupify'
# Private Data
gem 'figaro'
# Translate
gem 'i18n'
# Use slim format
gem 'slim-rails'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use postgres as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# gem 'yui-compressor'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'

# Use puma instead of WEBrick
gem 'puma'
# Use simple_form
gem 'simple_form'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.9'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 1.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.13'

# pagination
gem 'will_paginate'

# Continuation of CanCan (authoriation Gem for RoR)
gem 'cancancan'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
# Use Bootstrap (app/assets/stylesheets)
gem 'devise-bootstrap-views', '~> 1.0'
gem 'twitter-bootstrap-rails', git: 'git://github.com/seyhunak/twitter-bootstrap-rails.git'

gem 'acts-as-taggable-on', '~> 6.0'
gem 'better_errors' # !!!Important!!! move this to the development group before codeharbor goes really productive!!!Important!!!
gem 'font-awesome-rails'
gem 'jquery-ui-rails'
gem 'less-rails' # Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'nested_form_fields'
gem 'nokogiri'
gem 'oauth2', '~> 1.4.0'
gem 'select2-rails', '~> 4.0', '>= 4.0.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'factory_bot_rails', '~> 5.0.2'
  gem 'pry-byebug'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers', '~> 1.1.3'
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.72.0'
  gem 'rubocop-rails', '~> 2.2.0'
  gem 'rubocop-rspec', '~> 1.33.0'
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'rack-mini-profiler'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  gem 'airbrussh', require: false
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-rvm'
  gem 'capistrano-upload-config'
  gem 'capistrano3-puma'

  gem 'pry-rails'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
