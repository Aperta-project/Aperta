# In zsh, this is run as `rake 'db:import[SOURCEDB]'` where SOURCEDB is the heroku address or
# `rake db:import` for the tahi-staging db default

# To get a fresh backup of an environment, run `heroku pg:backups capture --app APPNAME`

namespace :db do
  desc "Import data from staging environment"
  task :import, [:source_db_name] => [:environment, :drop, :create] do |t, args|
    Bundler.with_clean_env do
      source_db = args[:source_db_name].present? ? args[:source_db_name] : 'tahi-staging'

      Tempfile.create("#{source_db}-import") do |f|
        target_db_name = ActiveRecord::Base.connection.current_database
        system("curl -o #{f.path} `heroku pg:backups public-url --app #{source_db}`")
        system("pg_restore --clean --no-acl --no-owner -h localhost -d #{target_db_name} #{f.path}")
        Journal.update_all(logo: nil)
        User.update_all(avatar: nil)
        User.all.each do |u|
          u.password = "password" # must be set explicitly
          u.save
        end
      end
    end
  end
end
