# yaml_db defines these, override them
Rake::Task["db:dump"].clear
Rake::Task["db:load"].clear

namespace :db do
  DEFAULT_USER_PASSWORD = "password".freeze

  desc <<-DESC
    Dumps slightly older prod database from internal network into development environment

    This also optionally accepts a variable that will pull in different environments if they are hosted on Hector.
    For example 'rake db:import_remote[rc]' will import in the rc environment instead,
    while 'rake db:import_remote[dev]' would pull in a 'dev' environment if
    'dev_dump.tar.gz' exists in bighector.
  DESC
  task :import_remote, [:env] => :environment do |_t, args|
    return unless Rails.env.development?
    env = args[:env] || 'prod'
    location = "http://bighector.plos.org/aperta/#{env}_dump.tar.gz"
    path = Rails.root.join("tmp", "#{env}_dump.tar.gz")

    # Download if newer than cached version
    rake_system_or_abort("curl -sH 'Accept-encoding: gzip' -o #{path} -z #{path} #{location}")

    # Restore database
    rake_reenable_and_invoke('db:restore', path)

    # run post import tasks
    ActiveRecord::Base.establish_connection
    rake_reenable_and_invoke('db:reset_passwords')
    rake_reenable_and_invoke('db:setup_role_accounts')
    puts("Successfully restored #{env} database\n")
  end

  desc "Test migrations against all known environments"
  task test_migrations: :environment do
    %w[prod stage rc].each do |env|
      rake_reenable_and_invoke('db:import_remote', env)
      rake_reenable_and_invoke('db:migrate')
    end
  end

  desc "Create seed data from the database"
  task dump_seed_data: :environment do
    Rake::Task['db:migrate'].invoke
    Rake::Task['cards:load'].invoke
    Rake::Task['roles-and-permissions:seed'].invoke
    Rake::Task['settings:seed_setting_templates'].invoke
    Rake::Task['data:update_journal_task_types'].invoke
    Rake::Task['institutional_accounts:add_seed_accounts'].invoke
    Rake::Task['create_feature_flags'].invoke
    Rake::Task['seed:letter_templates:populate'].invoke
    Rake::Task['db:data:dump'].invoke
  end

  desc "Dumps the database to ~/aperta-TIMESTAMP.dump"
  task dump: :environment do
    location = "~/aperta-#{Time.now.utc.strftime('%FT%H:%M:%SZ')}.dump"

    cmd = nil
    rake_with_db_config do |host, db, user|
      raise('Backup file already exists') if File.exist?(File.expand_path(location))
      cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{location}"
    end
    rake_system_or_abort(cmd, "Dump failed for \n #{cmd}")
  end

  desc "Cleans up the database dump files in ~, leaving the 2 newest"
  namespace :dump do
    task cleanup: :environment do
      require 'tahi_utilities/sweeper'
      TahiUtilities::Sweeper.remove_old_files(from_folder: '~', matching_glob: 'aperta-????-??-??T??:??:??Z.dump', keeping_newest: 2)
    end
  end

  desc "Restores the database dump at LOCATION"
  task :restore, [:location] => :environment do |_t, args|
    location = args[:location]
    abort('Location argument is required.') if location.blank?

    # Monkey patch db:drop and db:create not to catch exceptions so that if a
    # failure happens, this whole chain is aborted. See
    # https://github.com/rails/rails/pull/19924
    module ActiveRecord::Tasks::DatabaseTasks
      def drop(*arguments)
        configuration = arguments.first
        class_for_adapter(configuration['adapter']).new(*arguments).drop
      end

      def create(*arguments)
        configuration = arguments.first
        class_for_adapter(configuration['adapter']).new(*arguments).create
      end
    end

    rake_reenable_and_invoke('db:drop')
    rake_reenable_and_invoke('db:create')
    rake_with_db_config do |host, db, user|
      cat_bit = if location.to_s.ends_with?(".gz")
                  "gunzip -dc #{location}"
                else
                  "cat #{location}"
                end
      rake_system_or_abort(
        "#{cat_bit} | pg_restore --clean --if-exists --no-acl --no-owner --username #{user} --host #{host} --dbname #{db}"
      )
    end
  end

  # In zsh, this is run as `rake 'db:import_heroku[SOURCEDB]'` where SOURCEDB is the heroku address
  # (ie. 'tahi-lean-workflow')
  desc "Import data from the heroku staging environment"
  task :import_heroku, [:source_db_name] => [:environment] do |_t, args|
    raise "This can only be run in a development environment" unless Rails.env.development?
    source_db = args[:source_db_name]
    unless source_db
      raise <<-MSG.strip_heredoc
      You need to specify the heroku app you'd like to import from.
      `rake db:import_heroku[SOURCEDB]`
      where SOURCEDB is the name of the heroku app. (ie. 'tahi-lean-workflow')
      MSG
    end
    Rake::Task['db:drop'].invoke
    rake_system_or_abort("heroku pg:pull DATABASE_URL tahi_development --app #{source_db}")
    Rake::Task['db:reset_passwords'].invoke
    Rake::Task['db:setup_role_accounts'].invoke
  end

  desc <<-DESC
    Resets all user passwords

    This is used in several `rake db:` tasks that restore or dump the database to reset users passwords to "password" for fast troubleshooting in development.
  DESC
  task :reset_passwords => [:environment] do |_t, _args|
    raise "This can only be run in a development environment" unless Rails.env.development?
    Journal.update_all(logo: nil)
    encrypted_password = User.new(password: DEFAULT_USER_PASSWORD).encrypted_password
    User.update_all(encrypted_password: encrypted_password, avatar: nil)
  end

  desc <<-DESCRIPTION
    Adds a user account for each basic role, for use during development.
  DESCRIPTION
  task setup_role_accounts: [:environment] do
    raise "This can only be run in a development environment" unless Rails.env.development?

    default_role_user_attributes = {
      Role::ACADEMIC_EDITOR_ROLE => { username: "academic_editor", first_name: "Ace", last_name: "AcademicEditor" },
      Role::BILLING_ROLE => { username: "billing", first_name: "Bill", last_name: "Billing" },
      Role::COLLABORATOR_ROLE => { username: "collaborator", first_name: "Kelly", last_name: "Collaborator" },
      Role::COVER_EDITOR_ROLE => { username: "cover_editor", first_name: "Cuthbert", last_name: "CoverEditor" },
      Role::CREATOR_ROLE => { username: "creator", first_name: "Chris", last_name: "Creator" },
      Role::DISCUSSION_PARTICIPANT => { username: "discussion_participant", first_name: "Deke", last_name: "DiscussionParticipant" },
      Role::FREELANCE_EDITOR_ROLE => { username: "freelancer", first_name: "Fancy", last_name: "Freelancer" },
      Role::HANDLING_EDITOR_ROLE => { username: "handling_editor", first_name: "Helga", last_name: "HandlingEditor" },
      Role::INTERNAL_EDITOR_ROLE => { username: "editor", first_name: "Internal", last_name: "Editor" },
      Role::JOURNAL_SETUP_ROLE => { username: "journal_setup_admin", first_name: "Joanie", last_name: "JournalSetupAdmin" },
      Role::PRODUCTION_STAFF_ROLE => { username: "production_staff", first_name: "Priya", last_name: "ProductionStaff" },
      Role::PUBLISHING_SERVICES_ROLE => { username: "publishing_services", first_name: "Paddy", last_name: "PublishingServices" },
      Role::REVIEWER_REPORT_OWNER_ROLE => { username: "reviewer_report_owner", first_name: "Rory", last_name: "ReviewerReportOwner" },
      Role::REVIEWER_ROLE => { username: "reviewer", first_name: "Remi", last_name: "Reviewer" },
      Role::SITE_ADMIN_ROLE => { username: "site_admin", first_name: "Steve", last_name: "SiteAdmin" },
      Role::STAFF_ADMIN_ROLE => { username: "admin", first_name: "Adam", last_name: "Administrator" },
      Role::TASK_PARTICIPANT_ROLE => { username: "participant", first_name: "Prashanth", last_name: "Participant" },
      Role::USER_ROLE => { username: "author", first_name: "Arthur", last_name: "Author" }
    }.freeze

    Role.order(:name).uniq.each do |role|
      user_attributes = default_role_user_attributes[role.name]

      unless user_attributes
        STDOUT.write("Warning: Unable to find a Role with name '#{role.name}'")
        next
      end

      # create a new user
      user = User.find_or_create_by(username: user_attributes[:username]) do |user|
        user.attributes = user_attributes
        user.password = DEFAULT_USER_PASSWORD
        user.email = "#{user.username}@example.com"
      end

      # assign user to journal
      if journal = role.journal
        user.assign_to!(role: role, assigned_to: journal)
      end
    end
  end

  # These pollute the global namespace. Sorry.

  def rake_with_db_config
    ENV['PGPASSWORD'] = ActiveRecord::Base.connection_config[:password]
    yield ActiveRecord::Base.connection_config[:host],
          ActiveRecord::Base.connection_config[:database],
          ActiveRecord::Base.connection_config[:username]
    ENV.delete('PGPASSWORD')
  end

  def rake_system_or_abort(cmd, abort_message = nil)
    abort_message ||= "Error running #{cmd}"
    system(cmd) || abort("\e[31m#{abort_message}\e[0m")
  end

  def rake_reenable_and_invoke(task_name, *args)
    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke(*args)
  end
end
