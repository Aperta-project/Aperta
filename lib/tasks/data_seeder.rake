require 'fileutils'
# In zsh, this is run as `rake 'data:dump:scenario[SCENARIO]'`
# where SCENARIO is the name of the new scenario. Note the quotes.
# To retrieve the base seeding environment run:
# `rake 'data:dump:scenario[data]'`

load 'lib/ext/yaml_db.rb' # Only load the patch when running a data:dump or data:load rake task

namespace :data do
  desc <<-DESC.strip_heredoc
    A clean bare seed environment with no papers.
    This is the closest thing to a production seed for a new app.
  DESC
  task bare_seed: :environment do
    Rake::Task['db:schema:load'].invoke
    Journal.first_or_create!(name: 'PLOS Biology', logo: '', doi_publisher_prefix: "10.1371", doi_journal_prefix: "pbio", last_doi_issued: "0000001")

    Rake::Task['roles-and-permissions:seed'].invoke
    Rake::Task['data:update_journal_task_types'].invoke
    Rake::Task['journal:create_default_templates'].invoke
    Rake::Task['nested-questions:seed'].invoke

    puts 'Tahi Production Seeds have been loaded successfully'
  end

  namespace :dump do
    desc "Dump the current environment into a particular yaml file"
    task :scenario, [:scenario_name] => [:environment] do |t, args|
      if args[:scenario_name].present?
        scenario_path = Rails.root.join('db', 'seeds', args[:scenario_name])
        FileUtils.rmtree(scenario_path)
        YamlDb::SerializationHelper::Base.new('YamlDb::Helper'.constantize).dump_to_dir(scenario_path)
        puts "Successfully dumped db/seeds/#{args[:scenario_name]}"
      else
        puts "Scenario name is required. Run rake 'data:dump:scenario[SCENARIO]' where SCENARIO is the scenario name"
      end
    end
  end

  namespace :load do
    desc "Load a specific environment scenario from the name of the yaml file (without the extension)"
    task :scenario, [:scenario_name] => [:environment] do |t, args|
      if args[:scenario_name].present?
        scenario_path = Rails.root.join('db', 'seeds', args[:scenario_name])
        if File.directory?(scenario_path)
          YamlDb::SerializationHelper::Base.new('YamlDb::Helper'.constantize).load_from_dir(scenario_path)
          puts "Successfully loaded db/seeds/#{args[:scenario_name]}"
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
