# To seed a clean, bare environment with no papers run 'rake data:bare_seed'

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
