server 'aperta-frontend-401.soma.plos.org', user: 'aperta', roles: %w(web app)
server 'aperta-frontend-402.soma.plos.org', user: 'aperta', roles: %w(web app)
server 'tahi-worker-401.soma.plos.org', user: 'aperta',
                                        roles: %w(cron db worker)
server 'tahi-worker-402.soma.plos.org', user: 'aperta', roles: %w(db worker)
