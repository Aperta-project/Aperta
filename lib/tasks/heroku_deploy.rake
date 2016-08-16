
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
    DEPLOYING_APPS = ['tahi-lean-workflow', 'tahi-sandbox01']
    DEPLOYING_APPS = [args[:app]] if args[:app].present?
    fail "Please enter a version number. i.e. rake 'heroku:deploy[1.1.1]'" if args[:version].blank?
    threads = []
    DEPLOYING_APPS.each do |app|
      thread = Thread.new do
        begin
          system("heroku maintenance:on --app #{app}")
          tmp_directory = "tmp/#{app}.stdout.log"
          STDERR.puts "\r Deploying #{app} (outputting to #{tmp_directory})...\n"

          if system("bin/heroku_deploy #{app} #{args[:version]} &> #{tmp_directory}")
            STDERR.puts "\r \e[32m Successfully deployed to #{app}!\e[0m"
          else
            STDERR.puts "\r \e[31m Errors deploying to #{app} \n See the deploy log file for more information: #{tmp_directory}\e[0m"
          end
        ensure
          system("heroku maintenance:off --app #{app}")
          STDERR.puts " "
        end
      end
      spin_it(10) while thread.alive?
      threads << thread
    end
    threads.map(&:join)
    STDERR.puts "Deployment task complete"
  end
end

def spin_it(times)
  pinwheel = %w(| / - \\)
  times.times do
    print "\r"
    print "\b" + "\e[32m" + pinwheel.rotate!.first + "\e[0m"
    sleep(0.1)
    print "\r"
  end
end
