namespace :typesetter do
  require 'pp'

  desc <<-USAGE.strip_heredoc
    Displays typesetter metadata for manual inspection. Pass in paper id.
      Usage: rake typesetter:json[<paper_id>]
      Example: rake typesetter:json[5] (for paper with id 5)
  USAGE
  task :json, [:paper_id] => :environment do |_, args|
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    pp Typesetter::MetadataSerializer.new(Paper.find(args[:paper_id])).as_json
  end

  desc <<-USAGE.strip_heredoc
    Creates a typesetter ZIP file for manual inspection.
      Usage: rake typesetter:zip[<paper_id>,<output_filename>]
  USAGE
  task :zip, [:paper_id, :output_filename] => :environment do |_, args|
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    paper = Paper.find(args.paper_id)
    package = ApexPackager.create_zip(paper)
    FileUtils.cp(package.path, args[:output_filename])
  end
end
