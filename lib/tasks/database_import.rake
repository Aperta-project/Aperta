namespace :db do
  desc "Import data from staging environment"
  task :import => [:environment, :drop, :create]  do
    Bundler.with_clean_env do
      Tempfile.create('tahi-staging-import') do |f|
        Rake::Task['sunspot:solr:start'].execute
        target_db_name = ActiveRecord::Base.connection.current_database
        system("curl -o #{f.path} `heroku pgbackups:url --app tahi-staging`")
        system("pg_restore --clean --no-acl --no-owner -h localhost -d #{target_db_name} #{f.path}")
        Journal.update_all(logo: nil)
        User.update_all(avatar: nil)
        User.all.each do |u|
          u.password = "password" # must be set explicitly
          u.save
        end
        Rake::Task['sunspot:solr:stop'].execute
      end
    end
  end
end

