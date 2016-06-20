namespace :db do

  desc "Dumps slightly older prod database from internal network into development environment"
  task import_prod: :environment do
    return unless Rails.env.development?
    with_config do |app, host, db, user, password|
      ENV['PGPASSWORD'] = password.to_s
      cmd = "curl -sH 'Accept-encoding: gzip' 'http://bighector.plos.org/aperta/db_dump.tar.gz' | gunzip - | pg_restore --format=tar --verbose --clean --no-acl --no-owner -h #{host} -U #{user} -d #{db}"
      result = system(cmd)
      if result
        STDERR.puts("Successfully restored prod database by running \n #{cmd}")
      else
        STDERR.puts("Command failed to restore database")
      end
    end
  end

  desc "Dumps the database to ~/aperta.dump"
  task :dump_database, [:location] => :environment do |t, args|
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
  task restore_database: :environment do
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

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username],
      ActiveRecord::Base.connection_config[:password]
  end

end
