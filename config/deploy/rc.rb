set :rails_env, 'staging'
set :rack_env, 'staging'

ask :branch, proc {
  `git ls-remote --heads`.lines
    .map { |l| l.split(' ').last.strip }
    .select { |b| b =~ %r{^refs/heads/release/[0-9\.]+$} }
    .sort.last
}

server 'tahi-worker-201.sfo.plos.org', user: 'aperta', roles: %w(db worker)
server 'aperta-frontend-201.sfo.plos.org', user: 'aperta', roles: %w(web app)
