namespace :heroku do

  desc <<-DESC.strip_heredoc
    Allow incremental database migrations upon heroku deployments

    When a Github PR is opened, a heroku review app is automatically created.
    Heroku will automatically create an empty database with no database tables
    (equivalent to `db:create`).

    The first time that the PR is deployed to heroku, we want to ensure that
    the database tables are loaded and properly seeded using `db:setup`.  At a
    later point if a new migration is added to an existing PR, do not delete
    any existing data.  Instead, just run any pending migrations.

    This rake task is purposely being used instead of using the 'postdeploy'
    command in the heroku app.json manifest.  This is because postdeploy is
    executed only once when the heroku app is first created.  Additionally, it
    also runs AFTER the release command specified in the `Procfile`.
    Therefore, the release command cannot simply be `db:migrate` because Aperta
    does not guarantee that database migrations can be run from scratch on an
    empty database.  Running `db:migrate` on an empty database will fail.
    Instead, we only use `db:schema:load`.

    This rake task is expected to be called as part of the release command
    specified in the `Procfile` with no 'postdeploy' command specified in the
    heroku `app.json` manifest.
  DESC
  task release: :environment do
    if ActiveRecord::Migrator.current_version > 0
      # run any new migrations that have been added
      # since the last heroku deployment
      puts "Running database migration ..."
      Rake::Task['db:migrate'].invoke
    else
      # perform the initial database schema load
      puts "Running database setup ..."
      ['db:schema:load', 'db:data:load'].each do |task|
        Rake::Task[task].invoke
      end
    end
  end

  desc <<-DESC.strip_heredoc
    This deploys to our Heroku environments (defaults to tahi-lean-workflow and tahi-sandbox01).

    This optionally takes an app name if one wishes to deploy to a single Heroku environment.
    Examples:
      rake  heroku:deploy[1.5.1]
      rake  heroku:deploy[1.5.1,tahi-lean-workflow]

    The first command will deploy to tahi-lean-workflow and tahi-sandbox with version 1.5.1
    The second command will deploy only to tahi-lean-workflow with version 1.5.1

    Note: This will deploy from a release branch on origin, not from a local release branch.
  DESC
  task :deploy, [:version, :app] => [:environment] do |_, args|
    include Spinner
    DEPLOYING_APPS = ['tahi-lean-workflow', 'tahi-sandbox01']
    DEPLOYING_APPS = [args[:app]] if args[:app].present?
    fail "\n \e[31m Please enter a version number. i.e. rake 'heroku:deploy[1.1.1] \e[0m'" if args[:version].blank?
    unless system("git show-ref --quiet --verify refs/remotes/origin/release/#{args[:version]}")
      fail "\e[31m Remote release branch 'release/#{args[:version]}' has not been pushed up yet \e[0m"
    end
    threads = []
    DEPLOYING_APPS.each do |app|
      thread = Thread.new do
        begin
          system("heroku maintenance:on --app #{app}")
          log_file = "log/#{app}.log"
          # \r adds a carriage return so that the spinner does not appear with the message
          STDOUT.puts "\r Deploying #{app} (outputting to #{log_file})...\n"
          if system("bin/heroku_deploy #{app} #{args[:version]} &> #{log_file}")
            STDOUT.puts "\r \e[32m Successfully deployed to #{app}!\e[0m"
          else
            STDERR.puts "\r \e[31m Errors deploying to #{app} \n See the deploy log file for more information: #{log_file}\e[0m"
          end
        ensure
          system("heroku maintenance:off --app #{app}")
          STDOUT.puts " "
        end
      end
      threads << thread
    end
    spin_it(10) while threads.select(&:alive?).any?
    threads.map(&:join)
    STDOUT.puts "Deployment task complete"
  end
end
