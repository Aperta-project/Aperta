# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'tahi'
set :repo_url, 'git@github.com:Tahi-project/tahi.git'

# Default branch is :master
# Other ENVs are used by semaphore
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "leak"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/tahi"

# Default value for :scm is :git
set :scm, :git

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, false

# Link rails files
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/assets', 'public/system')

# Puma config
set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_default_control_app, "unix://#{shared_path}/tmp/sockets/pumactl.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [16, 16]
set :puma_workers, 2
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, true

# npm
set :npm_target_path, -> { "#{release_path}/client" }
set :bower_target_path, -> { "#{release_path}/client" }
set :bower_bin, "source ~/.profile && bower"

# release cycle
set :keep_releases, 3
