# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'tahi'
set :repo_url, 'git@github.com:tahi-project/tahi.git'
set :rails_env, 'production'
set :chruby_ruby, 'ruby-2.2.3'
set :chruby_exec, '/usr/bin/chruby-exec'
set :linked_files, %w(env.production puma.production.rb)
set :linked_dirs,
    %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/assets)

set :assets_roles, [:web]

set :web_service_name, 'tahi-web' # used by puma:{start,stop,restart}
set :worker_service_name, 'tahi-worker' # used by sidekiq:{start,stop,restart}

# ember-cli-rails compiles assets, but does not put them anywhere.
after 'deploy:compile_assets', 'deploy:copy_ember_assets'
