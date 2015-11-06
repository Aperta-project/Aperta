# rubocop:disable all
require 'fileutils'
# In zsh, this is run as `rake 'data:dump:scenario[SCENARIO]'`
# where SCENARIO is the name of the new scenario. Note the quotes.
namespace :data do
  namespace :dump do
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
    task :scenario, [:scenario_name] => [:environment] do |t, args|
      if args[:scenario_name].present?
        FileUtils.cp(Rails.root.join('db', 'seeds', "#{args[:scenario_name]}.yml"), Rails.root.join('db', 'data.yml'))
        Rake::Task['db:data:load'].invoke
        FileUtils.cp(Rails.root.join('db', 'seeds', 'data.yml'), Rails.root.join('db', 'data.yml')) # Restore base seed
        puts "Successfully loaded #{args[:scenario_name]}"
      else
        puts "Scenario name is required. Run rake 'data:load:scenario[SCENARIO]' where SCENARIO is the scenario name"
      end
    end
  end
end
# rubocop:enable all