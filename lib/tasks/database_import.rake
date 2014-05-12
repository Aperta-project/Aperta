namespace :db do
  desc "Import data from staging environment"
  task :import => [:environment, :drop, :create]  do
    Bundler.with_clean_env do
      dump_name = "staging-latest.sql"
      system("curl -o #{dump_name} `heroku pgbackups:url`")
      system("pg_restore --clean --no-acl --no-owner -h localhost -d tahi_development #{dump_name}")
      system("rm #{dump_name}")
    end
  end
end

