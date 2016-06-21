# yaml_db defines these, override them
Rake::Task["db:dump"].clear
Rake::Task["db:load"].clear

namespace :db do

  desc "Dumps slightly older prod database from internal network into development environment"
  task import_prod: :environment do
    return unless Rails.env.development?
    with_config do |app, host, db, user, password|
      ENV['PGPASSWORD'] = password.to_s
      cmd = "(curl -sH 'Accept-encoding: gzip' 'http://bighector.plos.org/aperta/db_dump.tar.gz' | gunzip - | pg_restore --format=tar --verbose --clean --no-acl --no-owner -h #{host} -U #{user} -d #{db}) && rake db:reset_passwords"
      result = system(cmd)
      if result
        STDERR.puts("Successfully restored prod database by running \n #{cmd}")
      else
        STDERR.puts("Command failed to restore database")
      end
    end
  end

  desc "Dumps the database to ~/aperta.dump"
  task :dump, [:location] => :environment do |t, args|
    location = args[:location] || '~/aperta.dump'

    cmd = nil
    with_config do |app, host, db, user, password|
      ENV['PGPASSWORD'] = password.to_s
      cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{location}"
      puts cmd
    end
    system(cmd) || STDERR.puts("Dump failed for \n #{cmd}") && exit(1)
  end

  desc "Restores the database dump at ~/aperta.dump"
  task restore: :environment do
    cmd = nil
    with_config do |app, host, db, user, password|
      ENV['PGPASSWORD'] = password.to_s
      cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} ~/aperta.dump"
    end
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    puts cmd
    system(cmd) || STDERR.puts("Restore failed for \n #{cmd}") && exit(1)
  end

  # In zsh, this is run as `rake 'db:import[SOURCEDB]'` where SOURCEDB is the heroku address or
  # `rake db:import` for the tahi-staging db default
  desc "Import data from the heroku staging environment"
  task :import_heroku, [:source_db_name] => [:environment] do |t, args|
    fail "This can only be run in a development environment" unless Rails.env.development?
    source_db = args[:source_db_name].present? ? args[:source_db_name] : 'tahi-staging'
    Rake::Task['db:drop'].invoke
    system("`(heroku pg:pull DATABASE_URL tahi_development --app #{source_db}) && rake db:reset_passwords`")
  end

  desc <<-DESC
    Resets all user passwords

    This is used in several `rake db:` tasks that restore or dump the database to reset users passwords to "password" for fast troubleshooting in development.
  DESC
  task :reset_passwords => [:environment] do |t, args|
    fail "This can only be run in a development environment" unless Rails.env.development?
    Journal.update_all(logo: nil)
    User.update_all(avatar: nil)
    User.all.each do |u|
      u.password = "password" # must be set explicitly
      u.save
    end
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username],
      ActiveRecord::Base.connection_config[:password]
  end

end
