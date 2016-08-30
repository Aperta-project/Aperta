server 'aperta-frontend-101.soma.plos.org', user: 'aperta', roles: %w(web app)
server 'aperta-frontend-102.soma.plos.org', user: 'aperta', roles: %w(web app)
server 'tahi-worker-101.soma.plos.org', user: 'aperta',
                                        roles: %w(cron db worker)
server 'tahi-worker-102.soma.plos.org', user: 'aperta', roles: %w(db worker)
