namespace :db do
  desc "Import data from staging environment"
  task :import => [:environment, :drop, :create]  do
    Bundler.with_clean_env do
      Tempfile.create('tahi-staging-import') do |f|
        target_db_name = ActiveRecord::Base.connection.current_database
        system("curl -o #{f.path} `heroku pgbackups:url --app tahi-staging`")
        system("pg_restore --clean --no-acl --no-owner -h localhost -d #{target_db_name} #{f.path}")
        Journal.update_all(logo: nil)
        User.all.each do |u|
          u.password = "password" # must be set explicitly
          u.avatar = nil # avoid 404s for s3 urls
          u.save
        end
      end
    end
  end
end

