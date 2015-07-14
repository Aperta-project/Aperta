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

# Default value for keep_releases is 5
set :keep_releases, 5
