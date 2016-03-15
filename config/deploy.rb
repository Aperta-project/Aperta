# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'tahi'
set :repo_url, 'git@github.com:tahi-project/tahi.git'
set :rails_env, 'production'
set :chruby_ruby, 'ruby-2.2.3'
set :chruby_exec, '/usr/bin/chruby-exec'
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('env.production')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

set :nginx_config_name, 'tahi.conf'

# Load from an env.production file managed by salt.
fetch(:bundle_bins).each do |command|
  SSHKit.config.command_map.prefix[command.to_sym].push("bundle exec dotenv -f env.production")
end

namespace :deploy do
  desc 'Load the database schema'
  task schema_load: [:set_rails_env] do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:schema:load'
        end
      end
    end
  end

  desc 'First deploy: loads database schema'
  task :cold do
    before 'deploy:updated', 'deploy:schema_load'
    invoke 'deploy'
  end

  desc 'Copy ember-built assets to public/client'
  task :copy_ember_assets do
    on release_roles(fetch(:assets_roles)) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rsync, '-a', 'tmp/ember-cli/apps/client/', 'public/client/'
        end
      end
    end
  end
end

# ember-cli-rails compiles assets, but does not put them anywhere.
after 'deploy:compile_assets', 'deploy:copy_ember_assets'

end
