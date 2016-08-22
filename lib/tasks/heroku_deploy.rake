
namespace :heroku do
  desc <<-DESC.strip_heredoc
    This deploys to our Heroku environments, tahi-lean-workflow, tahi-sandbox01

    This optionally takes an app name if one wishes to deploy to a single Heroku environment.
    Examples:
      rake  heroku:deploy[1.5.1]
      rake  heroku:deploy[1.5.1,tahi-lean-workflow]

    The first command will deploy to tahi-lean-workflow and tahi-sandbox with version 1.5.1
    The second command will deploy only to tahi-lean-workflow with version 1.5.1
    DESC

  task :deploy, [:version, :app] => [:environment] do |_, args|
    include Spinner
    DEPLOYING_APPS = ['tahi-lean-workflow', 'tahi-sandbox01']
    DEPLOYING_APPS = [args[:app]] if args[:app].present?
    fail "Please enter a version number. i.e. rake 'heroku:deploy[1.1.1]'" if args[:version].blank?
    threads = []
    DEPLOYING_APPS.each do |app|
      thread = Thread.new do
        begin
          system("heroku maintenance:on --app #{app}")
          log_file = "tmp/#{app}.stdout.log"
          STDERR.puts "\r Deploying #{app} (outputting to #{log_file})...\n"

          if system("bin/heroku_deploy #{app} #{args[:version]} &> #{log_file}")
            STDERR.puts "\r \e[32m Successfully deployed to #{app}!\e[0m"
          else
            STDERR.puts "\r \e[31m Errors deploying to #{app} \n See the deploy log file for more information: #{log_file}\e[0m"
          end
        ensure
          system("heroku maintenance:off --app #{app}")
          STDERR.puts " "
        end
      end
      threads << thread
    end
    spin_it(10) while threads.select(&:alive?).any?
    threads.map(&:join)
    STDERR.puts "Deployment task complete"
  end
end
