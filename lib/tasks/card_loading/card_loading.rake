require_relative "./support/card_loader.rb"

namespace :cards do
  desc "Load default Card models into the system"
  task load: :environment do
    puts "Loading legacy Cards unattached to any specific Journal ..."
    CardLoader.load_standard(journal: nil)

    puts "Loading Custom Cards attached to each Journal ..."
    CustomCard::Loader.all
  end

  desc "Loads one specific legacy card into the db for testing purposes. See card_configuration_sampler.rb"
  task :load_one, [:name, :journal] => :environment do |_, args|
    journal = args[:journal] ? Journal.find(args[:journal]) : nil

    puts "Loading single legacy Card unattached to any specific Journal..."
    CardLoader.load(args[:name], journal: journal)
  end
end
