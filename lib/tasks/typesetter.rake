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

namespace :typesetter do
  require 'pp'

  desc <<-USAGE.strip_heredoc
    Displays typesetter metadata for manual inspection. Pass in paper id.
      Usage: rake typesetter:json[<paper_id>, <destination>]
      Example: rake typesetter:json[5, em] (for paper with id 5 and destination em)
  USAGE
  task :json, [:paper_id, :destination] => :environment do |_, args|
    destination = args[:destination] || 'apex'
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    pp Typesetter::MetadataSerializer.new(Paper.find(args[:paper_id]), destination: destination).as_json
  end

  desc <<-USAGE.strip_heredoc
    Creates a typesetter ZIP file for manual inspection.
      Usage: rake typesetter:zip[<paper_id>,<output_filename>, <destination>]
  USAGE
  task :zip, [:paper_id, :output_filename, :destination] => :environment do |_, args|
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    paper = Paper.find(args.paper_id)
    package = ExportPackager.create_zip(paper, destination: args.destination)
    FileUtils.cp(package.path, args[:output_filename])
  end
end
