set :rails_env, 'staging'
set :rack_env, 'staging'
set :branch, 'master'

server 'tahi-worker-201.sfo.plos.org', user: 'aperta', roles: %w(db worker)
server 'aperta-frontend-201.sfo.plos.org', user: 'aperta', roles: %w(web app)
