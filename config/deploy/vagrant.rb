set :rails_env, 'staging'
set :rack_env, 'staging'
ask :branch, `git rev-parse --abbrev-ref HEAD`.strip

server 'aperta', user: 'aperta', roles: %w(app cron db web worker)
