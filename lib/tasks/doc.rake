require 'sdoc'
require 'rdoc/task'
require 'rails/tasks'

# Override default `doc:app`
Rake::Task["doc:app"].clear

namespace :doc do
  RDoc::Task.new('app') do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.generator = 'sdoc'
    rdoc.template = 'rails'
    rdoc.title = 'Tahi Documentation'
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('README.md')
    rdoc.main = 'README.md'
  end

  Rake::Task['doc:app'].enhance do
    # generate js docs
    system("cd client && node_modules/.bin/yuidoc . -x tmp,bower_components -o ../doc/yuidoc/")
  end
end
