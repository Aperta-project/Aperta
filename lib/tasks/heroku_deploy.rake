
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
