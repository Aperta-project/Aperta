class ManualSeeds # Use this class to run seeds the old way
  require 'rake'
  def self.run
    Rake::Task['db:schema:load'].invoke
    # Create Journal
    plos_journal = Journal.first_or_create! name: 'PLOS Biology',
                                            logo: '',
                                            doi_publisher_prefix: "10.1371",
                                            doi_journal_prefix: "pbio",
                                            first_doi_number: "0000001"

    Rake::Task['roles-and-permissions:seed'].invoke
    Rake::Task['data:update_journal_task_types'].invoke
    Rake::Task['journal:create_default_templates'].invoke
    Rake::Task['nested-questions:seed'].invoke

    puts 'Tahi Production Seeds have been loaded successfully'
  end
end


# To generate BASE seed data, run `rake db:data:dump` to dump
# the current state of the database in `db/data.yml`.

# To load data, run `rake db:data:load` to load
# the saved environment

# To save a scenario, run `rake 'data:dump:scenario[SCENARIO]'`
# To load a scenario, run `rake 'data:load:scenario[SCENARIO]'` where SCENARIO is the scenario name

if Rails.env.production?
  # don't run seeds in production
else
  Rake::Task['db:data:load'].invoke
  puts "Tahi Seeds have been loaded successfully"
end
