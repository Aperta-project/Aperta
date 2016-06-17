namespace :db do

  desc "Dumps the database to db/APP_NAME.dump"
  task dump_database: :environment do
    cmd = nil
    with_config do |app, host, db, user, password|
      cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > ~/aperta.dump"
      puts cmd
      cmd = "PGPASSWORD='#{password}' " + cmd
    end
    exec cmd
  end

  desc "Restores the database dump at db/APP_NAME.dump."
  task restore_database: :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} ~/aperta.dump"
    end
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    puts cmd
    exec cmd
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
