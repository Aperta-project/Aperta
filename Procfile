web: bundle exec puma
worker: bundle exec sidekiq -C config/sidekiq.heroku.yml
release: rake db:migrate
