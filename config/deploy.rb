# frozen_string_literal: true

set :application, 'codeharbor'
set :config_example_suffix, '.example'
set :deploy_to, '/home/codeharbor'
set :keep_releases, 3
set :linked_files, %w[config/action_mailer.yml config/database.yml]
set :linked_dirs, %w[log tmp/backup tmp/pids tmp/cache tmp/sockets]
set :log_level, :info
set :puma_threads, [0, 16]
set :repo_url, 'git@github.com:openHPI/codeharbor.git'

namespace :deploy do
  before 'check:linked_files', 'config:push'

  after :compile_assets, :copy_vendor_assets do
    on roles(fetch(:assets_roles)) do
      within release_path do
        execute :cp, '-r', 'vendor/assets/images', 'public/assets/'
        execute :cp, '-r', 'vendor/assets/javascripts/ace', 'public/assets/'
      end
    end
  end
end
