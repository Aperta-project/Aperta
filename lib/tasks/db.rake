# yaml_db defines these, override them
Rake::Task["db:dump"].clear
Rake::Task["db:load"].clear

namespace :db do
  PG_RESTORE_ARGS = "--verbose --clean --if-exists --no-acl --no-owner".freeze

  task :ensure_dev do
    raise "This can only be run in a development environment" unless Rails.env.development?
  end

  desc <<-DESC
    Dumps slightly older prod database from internal network into development environment

    This also optionally accepts a variable that will pull in different environments if they are hosted on Hector.
    For example 'rake db:import_remote[rc]' will import in the rc environment instead,
    while 'rake db:import_remote[dev]' would pull in a 'dev' environment if
    'dev_dump.tar.gz' exists in bighector.
  DESC
  task :import_remote, [:env] => [:environment, :ensure_dev] do |_, args|
    env = (args[:env] || 'prod')
    location = "http://bighector.plos.org/aperta/#{env}_dump.tar.gz"

    drop_db
    create_db
    with_config do |host, db, user|
      cmd = "(curl -sH 'Accept-encoding: gzip' #{location} | gunzip - | pg_restore --format=tar #{PG_RESTORE_ARGS} -h #{host} -U #{user} -d #{db}) && rake db:reset_passwords"
      if system(cmd)
        STDERR.puts("Successfully restored #{env} database by running \n #{cmd}")
      else
        STDERR.puts("Restored #{env} with errors or warnings")
      end
    end
  end

  desc "Dumps the database to ~/aperta-TIMESTAMP.dump"
  task dump: :environment do
    location = "~/aperta-#{Time.now.utc.strftime('%FT%H:%M:%SZ')}.dump"

    with_config do |host, db, user|
      raise('Backup file already exists') if File.exist?(File.expand_path(location))
      cmd = "pg_dump --host #{host} --username #{user} --verbose --format=c #{db} > #{location}"
      system(cmd) || raise("Dump failed for \n #{cmd}")
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
      drop_db
      create_db
      with_config do |host, db, user|
        cmd = "pg_restore --host #{host} --username #{user} #{PG_RESTORE_ARGS} --dbname #{db} #{location}"
        puts cmd
        system(cmd) || raise("Restore failed for \n #{cmd}")
      end
    else
      STDERR.puts('Location argument is required.')
    end
  end

  # In zsh, this is run as `rake 'db:import_heroku[SOURCEDB]'` where SOURCEDB is the heroku address
  # (ie. 'tahi-lean-workflow')
  desc "Import data from the heroku staging environment"
  task :import_heroku, [:source_db_name] => [:environment, :ensure_dev] do |_, args|
    source_db = args[:source_db_name]
    unless source_db
      raise <<-MSG.strip_heredoc
      You need to specify the heroku app you'd like to import from.
      `rake db:import_heroku[SOURCEDB]`
      where SOURCEDB is the name of the heroku app. (ie. 'tahi-lean-workflow')
      MSG
    end
    drop_db
    with_config do |host, db, user|
      local_db = URI::Generic.new("postgres", user, host, nil, nil, "/#{db}", nil, nil, nil)
      system("heroku pg:pull DATABASE_URL #{local_db} --app #{source_db} && rake db:reset_passwords")
    end
  end

  desc <<-DESC
    Resets all user passwords

    This is used in several `rake db:` tasks that restore or dump the database to reset users passwords to "password" for fast troubleshooting in development.
  DESC
  task reset_passwords: [:environment, :ensure_dev] do |_, _|
    Journal.update_all(logo: nil)
    User.update_all(avatar: nil)
    User.all.each do |u|
      u.password = "password" # must be set explicitly
      u.save
    end
  end

  private

  def with_config
    ENV['PGPASSWORD'] = ActiveRecord::Base.connection_config[:password].to_s
    yield ActiveRecord::Base.connection_config[:host],
          ActiveRecord::Base.connection_config[:database],
          ActiveRecord::Base.connection_config[:username]
  end

  def create_db
    with_config do |host, db, user|
      # ensure that there is no connection to the database since we're
      # about to drop and recreate it.
      ActiveRecord::Base.connection.disconnect!
      unless system("createdb -h #{host} -U #{user} #{db}")
        raise "\e[31m Error dropping and creating blank database. Is #{db} in use?\e[0m"
      end
    end
  end

  def drop_db
    with_config do |host, db, user|
      # ensure that there is no connection to the database since we're
      # about to drop and recreate it.
      ActiveRecord::Base.connection.disconnect!
      unless system("dropdb -h #{host} -U #{user} #{db}")
        raise "\e[31m Error dropping database. Is #{db} in use?\e[0m"
      end
    end
  end
end
