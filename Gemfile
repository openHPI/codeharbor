source 'https://rubygems.org'

#Handle Group Access
gem 'groupify'
#Private Data
gem 'figaro'
#Translate
gem 'i18n'
#Use slim format
gem 'slim-rails'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use sqlite3 as the database for Active Record
#gem 'sqlite3'
# Use postgres as the database for Active Record
gem 'pg', platform: :ruby
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'yui-compressor'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use puma instead of WEBrick
gem 'puma'
#Use simple_form
gem 'simple_form'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

#pagination
gem 'will_paginate'

# Continuation of CanCan (authoriation Gem for RoR)
gem 'cancancan'

# Use Bootstrap (app/assets/stylesheets)
gem 'therubyracer', platforms: :ruby
gem 'twitter-bootstrap-rails'
gem 'devise-bootstrap-views'

gem 'nested_form_fields'

gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS

gem 'jquery-ui-rails'
gem 'select2-rails', '~> 4.0', '>= 4.0.3'

gem 'oauth2'
gem 'nokogiri'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.0'
  gem "factory_girl_rails", "~> 4.0"
end

group :development do
  gem 'rack-mini-profiler'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  
  gem "capistrano", "~> 3.6"
  gem 'capistrano3-puma'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-upload-config'
  gem 'airbrussh', require: false

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'simplecov', :require => false
end
