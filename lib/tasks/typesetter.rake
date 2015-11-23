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
end
