require_relative "./support/card_loader.rb"

namespace :cards do
  desc "Create Card models without a specific Journal association"
  task load: :environment do
    puts "Loading Cards unattached to any specific Journal..."

    CardLoader.load_all(journal: nil)
  end
end
