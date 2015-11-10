# rubocop:disable all
require 'fileutils'
# In zsh, this is run as `rake 'data:dump:scenario[SCENARIO]'`
# where SCENARIO is the name of the new scenario. Note the quotes.
# To retrieve the base seeding environment run:
# `rake 'data:dump:scenario[data]'`

load 'lib/ext/yaml_db.rb' # Only load the patch when running a data:dump or data:load rake task

namespace :data do
  namespace :dump do
    desc "Dump the current environment into a particular yaml file"
    task :scenario, [:scenario_name] => [:environment] do |t, args|
      if args[:scenario_name].present?
        Rake::Task['db:data:dump'].invoke
        FileUtils.cp(Rails.root.join('db', 'data.yml'), Rails.root.join('db', 'seeds', "#{args[:scenario_name]}.yml"))
        FileUtils.cp(Rails.root.join('db', 'seeds', 'data.yml'), Rails.root.join('db', 'data.yml')) # Restore base seed
        puts "Successfully dumped #{args[:scenario_name]}.yml"
      else
        puts "Scenario name is required. Run rake 'data:dump:scenario[SCENARIO]' where SCENARIO is the scenario name"
      end
    end
  end

  namespace :load do
    desc "Load a specific environment scenario from the name of the yaml file (without the extension)"
    task :scenario, [:scenario_name] => [:environment] do |t, args|
      if args[:scenario_name].present?
        file_path = Rails.root.join('db', 'seeds', "#{args[:scenario_name]}.yml")
        if File.exist?(file_path)
          FileUtils.cp(file_path, Rails.root.join('db', 'data.yml'))
          Rake::Task['db:data:load'].invoke
          FileUtils.cp(Rails.root.join('db', 'seeds', 'data.yml'), Rails.root.join('db', 'data.yml')) # Restore base seed
          puts "Successfully loaded #{args[:scenario_name]}"
        else
          puts <<-eos
            Load FAILED. ScenarioNotFound "#{args[:scenario_name]}". 

            The scenario name should match a filename in db/seeds/ without the extension. Possible scenarios are:
              - empty-paper
              - paper-with-tasks-unsubmitted
              - paper-with-tasks-submitted
              - paper-on-second-round
          eos
        end
      else
        puts "Scenario name is required. Run rake 'data:load:scenario[SCENARIO]' where SCENARIO is the scenario name"
      end
    end
  end
end
# rubocop:enable all