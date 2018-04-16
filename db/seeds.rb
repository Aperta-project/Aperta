# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class ManualSeeds # Use this class to run seeds the old way
  require 'rake'
  def self.run
    Rake::Task['db:schema:load'].invoke
    # Create Journal
    plos_journal = Journal.first_or_create!(name: 'PLOS Biology', logo: '', doi_publisher_prefix: "10.1371", doi_journal_prefix: "pbio", last_doi_issued: "0000001")

    Rake::Task['cards:load'].invoke
    Rake::Task['roles-and-permissions:seed'].invoke
    Rake::Task['data:update_journal_task_types'].invoke
    Rake::Task['journal:create_default_templates'].invoke
    Rake::Task['settings:seed_setting_templates'].invoke
    Rake::Task['create_feature_flags'].invoke
    Rake::Task['seed:letter_templates:populate'].invoke

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
