require_relative "./support/card_loader.rb"

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
