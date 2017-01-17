# yaml_db defines these, override them
Rake::Task["db:dump"].clear
Rake::Task["db:load"].clear

namespace :db do
  desc <<-DESC
    Dumps slightly older prod database from internal network into development environment

    This also optionally accepts a variable that will pull in different environments if they are hosted on Hector.
    For example 'rake db:import_remote[rc]' will import in the rc environment instead,
    while 'rake db:import_remote[dev]' would pull in a 'dev' environment if
    'dev_dump.tar.gz' exists in bighector.
  DESC
  task :import_remote, [:env] => :environment do |_, args|
    ensure_dev
    args[:env] = nil if args[:env] == 'prod'
    env = args[:env]
    location = "http://bighector.plos.org/aperta/#{env || 'prod'}_dump.tar.gz"

    with_config do |host, db, user|
      # ensure that there is no connection to the database since we're
      # about to drop and recreate it.
      ActiveRecord::Base.connection.disconnect!

      args = " -h #{host} -U #{user} "

      drop_cmd = system("dropdb #{args} #{db} && createdb #{args} #{db}")
      raise "\e[31m Error dropping and creating blank database. Is #{db} in use?\e[0m" unless drop_cmd

      cmd = "(curl -sH 'Accept-encoding: gzip' #{location} | gunzip - | pg_restore --format=tar --verbose --clean --no-acl --no-owner #{args} -d #{db}) && rake db:reset_passwords"
      result = system(cmd)
      if result
        STDERR.puts("Successfully restored #{env || 'prod'} database by running \n #{cmd}")
      else
        STDERR.puts("Restored #{env || 'prod'} with errors or warnings")
      end
    end
  end

  desc "Dumps the database to ~/aperta-TIMESTAMP.dump"
  task dump: :environment do
    location = "~/aperta-#{Time.now.utc.strftime('%FT%H:%M:%SZ')}.dump"

    with_config do |host, db, user|
      raise('Backup file already exists') if File.exist?(File.expand_path(location))
      cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{location}"
      system(cmd) || STDERR.puts("Dump failed for \n #{cmd}") && exit(1)
    end
  end

  desc "Cleans up the database dump files in ~, leaving the 2 newest"
  namespace :dump do
    task cleanup: :environment do
      require 'tahi_utilities/sweeper'
      TahiUtilities::Sweeper.remove_old_files(from_folder: '~', matching_glob: 'aperta-????-??-??T??:??:??Z.dump', keeping_newest: 2)
    end
  end

  desc "Restores the database dump at LOCATION"
  task :restore, [:location] => :environment do |_, args|
    location = args[:location]
    if location
      with_config do |host, db, user|
        cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{location}"
        puts cmd
        system(cmd) || STDERR.puts("Restore failed for \n #{cmd}") && exit(1)
      end
    else
      STDERR.puts('Location argument is required.')
    end
  end

  # In zsh, this is run as `rake 'db:import_heroku[SOURCEDB]'` where SOURCEDB is the heroku address
  # (ie. 'tahi-lean-workflow')
  desc "Import data from the heroku staging environment"
  task :import_heroku, [:source_db_name] => [:environment] do |_, args|
    ensure_dev
    source_db = args[:source_db_name]
    unless source_db
      raise <<-MSG.strip_heredoc
      You need to specify the heroku app you'd like to import from.
      `rake db:import_heroku[SOURCEDB]`
      where SOURCEDB is the name of the heroku app. (ie. 'tahi-lean-workflow')
      MSG
    end
    Rake::Task['db:drop'].invoke
    system("`(heroku pg:pull DATABASE_URL tahi_development --app #{source_db}) && rake db:reset_passwords`")
  end

  desc <<-DESC
    Resets all user passwords

    This is used in several `rake db:` tasks that restore or dump the database to reset users passwords to "password" for fast troubleshooting in development.
  DESC
  task reset_passwords: [:environment] do |_, _|
    ensure_dev
    Journal.update_all(logo: nil)
    User.update_all(avatar: nil)
    User.all.each do |u|
      u.password = "password" # must be set explicitly
      u.save
    end
  end

  private

  def ensure_dev
    raise "This can only be run in a development environment" unless Rails.env.development?
  end

  def with_config
    ENV['PGPASSWORD'] = ActiveRecord::Base.connection_config[:password].to_s
    yield ActiveRecord::Base.connection_config[:host],
          ActiveRecord::Base.connection_config[:database],
          ActiveRecord::Base.connection_config[:username]
  end
end
