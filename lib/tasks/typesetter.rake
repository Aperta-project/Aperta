namespace :typesetter do
  require 'pp'

  desc <<-USAGE.strip_heredoc
    Displays typesetter metadata for manual inspection. Pass in paper id.
      Usage: rake typesetter:json[<paper_id>]
      Example: rake typesetter:json[5] (for paper with id 5)
  USAGE

  task :json, [:paper_id] => :environment do |t, args|
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    pp Typesetter::MetadataSerializer.new(Paper.find(args[:paper_id])).as_json
  end

  desc 'Creates an Apex ZIP.  Usage "rake apex:export[<paper id>,<filename>]"'
  task :export, [:paper_id, :filename] => :environment do |_, args|
    $stdout.puts 'Beginning export'
    paper = Paper.find(args.paper_id)
    package = ApexPackager.create(paper)
    File.open(args.filename, 'w') { |f| f.write(package) }
  end
end
