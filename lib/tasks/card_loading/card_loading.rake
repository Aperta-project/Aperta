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

require_relative "./support/card_loader.rb"
require 'custom_card/file_loader'

namespace :cards do
  desc "Load default Card models into the system"
  task load: [:environment, 'card_task_types:seed'] do
    puts "Loading legacy Cards unattached to any specific Journal ..."
    CardLoader.load_standard(journal: nil)
    puts "Loading Custom Cards attached to each Journal ..."
    CustomCard::FileLoader.all
  end

  desc "Loads one custom card into a journal"
  task :load_one, [:path, :journal] => :environment do |_, args|
    journal = args[:journal] ? Journal.find(args[:journal]) : nil
    path = args[:name]
    puts "Loading card from #{path} to journal #{journal.name}"
    CardLoader::FileLoader.new(journal).load_card(path)
  end
end
