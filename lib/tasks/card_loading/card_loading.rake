require_relative "./support/card_loader.rb"

namespace :cards do
  desc "Create Card models without a specific Journal association"
  task load: :environment do
    puts "Loading Cards unattached to any specific Journal..."

    CardLoader.load_standard(journal: nil)
  end

  desc "Loads one specific card into the db for testing purposes. See card_configuration_sampler.rb"
  task :load_one, [:name, :journal] => :environment do |_, args|
    puts "Loading..."
    journal = args[:journal] ? Journal.find(args[:journal]) : nil
    CardLoader.load(args[:name], journal: journal)
  end
end
