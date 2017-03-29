require_relative "./support/card_loader.rb"

namespace :cards do
  desc "Create Card models without a specific Journal association"
  task load: :environment do
    puts "Loading Cards unattached to any specific Journal..."

    # To avoid id collision on the ember side, where we are making CardContent
    # look like NestedQuestion, do not reuse ids.
    start = NestedQuestion.pluck(:id).max.try(:+, 1)
    if start.present?
      $stderr.puts("Starting CardContent.id sequence at #{start}")
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE card_contents_id_seq RESTART WITH #{start}")
    end

    CardLoader.load_standard(journal: nil)
  end

  task :load_one, [:name, :journal] => :environment do |_, args|
    puts "Loading..."
    journal = args[:journal] ? Journal.find(args[:journal]) : nil
    CardLoader.load(args[:name], journal: journal)
  end
end
