set :rails_env, 'production'
set :rack_env, 'production'
# Deploy the currently checked out SHA1 hash.
set :branch, `git rev-parse HEAD`

server 'aperta-frontend-101.soma.plos.org', user: 'aperta', roles: %w(web app)
server 'aperta-frontend-102.soma.plos.org', user: 'aperta', roles: %w(web app)
server 'tahi-worker-101.soma.plos.org', user: 'aperta', roles: %w(db worker)
server 'tahi-worker-102.soma.plos.org', user: 'aperta', roles: %w(db worker)
