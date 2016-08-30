ask :branch, `git rev-parse --abbrev-ref HEAD`.strip

server 'aperta', user: 'aperta', roles: %w(app cron db web worker)
