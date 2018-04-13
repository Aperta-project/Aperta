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
