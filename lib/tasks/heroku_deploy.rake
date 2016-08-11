namespace :heroku do
  desc <<-DESC.strip_heredoc
    This deploys to our Heroku environments, tahi-lean-workflow, tahi-sandbox01

    This optionally takes an app name if one wishes to deploy to a single Heroku environment.
    Examples:
      rake  heroku:deploy[1.5.11]
      rake  heroku:deploy[1.5.11,tahi-lean-workflow]

    The first command will deploy to tahi-lean-workflow and tahi-sandbox with version 1.5.11
    The second command will deploy only to tahi-lean-workflow with version 1.5.11
    DESC
  task :deploy, [:version, :app] => [:environment] do |_, args|
    # DEPLOYING_APPS = ['tahi-lean-workflow', 'tahi-sandbox01']
    DEPLOYING_APPS = ['ciagent-stage-pr-2527', 'ciagent-stage-pr-2528']
    DEPLOYING_APPS = [args[:app]] if args[:app].present?
    puts "Deploying #{DEPLOYING_APPS.join(', ')}..."
    fail "Please enter a version number. i.e. rake 'heroku:deploy[1.1.1]'" if args[:version].blank?
    threads = []
    DEPLOYING_APPS.each do |app|
      commands = []
      commands << "heroku maintenance:on --app #{app}"     # Maintenance on
      commands << "heroku pg:backups capture --app #{app}" # Backup database
      commands << "git push -f git@heroku.com:#{app}.git release/#{args[:version]}:master" # Deploy
      # Migrations
      commands << "heroku run bundle exec rake db:migrate nested-questions:seed roles-and-permissions:seed --app #{app}"
      # Maintenance off
      commands << "heroku maintenance:off --app #{app}"

      threads << Thread.new do
        system(commands.join(' &&'))
      end
    end
    threads.map(&:join)
    puts "Deployment task complete"
  end
end
