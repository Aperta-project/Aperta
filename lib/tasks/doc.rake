require 'rails/tasks'
require 'sdoc'
require 'rdoc/task'

# Override default `doc:app`
Rake::Task["doc:app"].clear

namespace :doc do
  RDocTaskWithoutDescriptions.new('app') do |rdoc|
    # Must use this option to get the github option to work
    rdoc.options << '--format=sdoc'
    rdoc.options << '--github'
    rdoc.template = 'rails'
    rdoc.rdoc_dir = 'doc/api'
    rdoc.title = 'Tahi API Documentation'
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('README.md')
    rdoc.main = 'README.md'
  end
  Rake::Task['doc:app'].comment = "Generate docs for Tahi"
  Rake::Task['doc:app'].enhance do
    # generate js docs
    # See `client/yuidoc.json` for options
    system("cd client && node_modules/.bin/yuidoc .")
  end
end
