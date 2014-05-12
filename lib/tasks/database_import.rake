namespace :db do
  desc "Import data from staging environment"
  task :import => [:environment, :drop, :create]  do
    Bundler.with_clean_env do
      Tempfile.create('tahi-staging-import') do |f|
        system("curl -o #{f.path} `heroku pgbackups:url`")
        system("pg_restore --clean --no-acl --no-owner -h localhost -d tahi_development #{f.path}")
      end
    end
  end
end

