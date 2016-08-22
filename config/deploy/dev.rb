set :rails_env, 'staging'
set :rack_env, 'staging'

# Teamcity sets BRANCH_NAME
set :branch, ENV['BRANCH_NAME'] || 'master'

server 'tahi-worker-201.sfo.plos.org', user: 'aperta', roles: %w(cron db worker)
server 'aperta-frontend-201.sfo.plos.org', user: 'aperta', roles: %w(web app)
