namespace :typesetter do
  require 'pp'

  desc 'Displays typesetter metadata for manual inspection. Pass in paper id.'
  task :json, [:paper_id] => :environment do |t, args|
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    pp Typesetter::MetadataSerializer.new(Paper.find(args[:paper_id])).as_json
  end
end
