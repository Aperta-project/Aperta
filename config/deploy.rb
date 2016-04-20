# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'tahi'
set :assets_roles, [:web]
set :chruby_exec, '/usr/bin/chruby-exec'
set :chruby_ruby, File.read(File.expand_path('../../.ruby-version', __FILE__)).strip
unless ENV['HIPCHAT_AUTH_TOKEN'].nil?
  set :hipchat_room_name, '1777105'
  set :hipchat_options, api_version: 'v2'
  set :hipchat_token, ENV.fetch('HIPCHAT_AUTH_TOKEN')
end
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle)
set :linked_files, %w(env puma.rb)
set :repo_url, 'git@github.com:tahi-project/tahi.git'
set :web_service_name, 'tahi-web' # used by puma:{start,stop,restart}
set :worker_service_name, 'tahi-worker' # used by sidekiq:{start,stop,restart}

# Load from an env file managed by salt.
fetch(:bundle_bins).each do |command|
  SSHKit.config.command_map.prefix[command.to_sym]
    .push('bundle exec dotenv -f env')
end

# ember-cli-rails compiles assets, but does not put them anywhere.
after 'deploy:compile_assets', 'deploy:copy_ember_assets'
