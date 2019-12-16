# frozen_string_literal: true

source 'https://rubygems.org'

gem 'proforma', git: 'git://github.com/openHPI/proforma.git' # use version not master
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
gem 'slim-rails', '>= 3.2.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use postgres as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# gem 'yui-compressor'

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
gem 'font-awesome-rails', '>= 4.7.0.5'
gem 'jquery-ui-rails', '>= 6.0.1'
gem 'less-rails', '>= 3.0.0' # Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'nested_form_fields', '>= 0.8.2'
gem 'nokogiri'
gem 'oauth2', '~> 1.4.0'
gem 'select2-rails', '~> 4.0', '>= 4.0.3'
gem 'sprockets', '~> 3.7.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'factory_bot_rails', '~> 5.1.1'
  gem 'pry-byebug'
  gem 'rails-controller-testing', '>= 1.0.4'
  gem 'rspec-collection_matchers', '~> 1.1.3'
  gem 'rspec-rails', '>= 3.8.2'
  gem 'rubocop', '~> 0.77.0'
  gem 'rubocop-performance', '~> 1.5.1'
  gem 'rubocop-rails', '~> 2.4.0'
  gem 'rubocop-rspec', '~> 1.37.0'
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'rack-mini-profiler'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 3.7.0'

  gem 'airbrussh', require: false
  gem 'capistrano', '~> 3.11', require: false
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
