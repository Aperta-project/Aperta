# How to export data from Aperta

## Exporting database
- `ssh aperta@aperta-frontend-101.soma.plos.org`
- `cd /var/www/tahi/current`
- `bede rake db:dump`
- `ls -l ~/aperta*` (to get the filename, e.g. `aperta-2021-06-21T16:23:32Z.dump`)

## Restore the data
- `docker-compose build`
- `cp .env.docker.example .env.docker`
- Edit `.env.docker` to add AWS keys
- `rsync aperta@aperta-frontend-101.soma.plos.org:aperta-2021-06-21T16:23:32Z.dump db.dump`
- `docker-compose -f docker-compose.yml -f docker-compose.restore.yml up`
- `docker-compose -f docker-compose.yml -f docker-compose.export.yml up --abort-on-container-exit`
