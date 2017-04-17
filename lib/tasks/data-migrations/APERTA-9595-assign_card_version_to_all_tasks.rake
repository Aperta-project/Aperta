require Rails.root.join("lib/tasks/card_loading/support/card_factory.rb")

namespace :data do
  namespace :migrate do
    desc <<-DESC
      Create Cards for legacy (non-CustomCard) Tasks.
    DESC
    task add_legacy_cards: :environment do
      STDOUT.puts "-------------------------------------"
      STDOUT.puts "Adding Cards for legacy Tasks ..."
      LegacyTaskCardLoader.new.load
      STDOUT.puts "-------------------------------------"
    end

    desc <<-DESC
      Assign a Card version to Tasks that do not currently have one assigned.
    DESC
    task assign_card_version_to_all_tasks: [:environment, :add_legacy_cards] do
      STDOUT.puts "-------------------------------------"
      tasks = Task.where(card_version_id: nil)
      STDOUT.puts "Updating #{tasks.count} Tasks that do not have a Card association ..."

      # assign a CardVersion for each Task
      tasks.find_each do |task|
        card = Card.find_by(name: LookupClassNamespace.lookup_namespace(task.type))
        raise "Could not find card for #{task.type}" if card.nil?
        task.update_attribute(:card_version_id, card.latest_card_version.id)
      end

      # assert that all Tasks have an associated CardVersion
      if tasks.reload.any?
        message = "Not all Tasks were assigned an associated CardVersion"
        STDERR.puts(message)
        raise message
      end

      STDOUT.puts "Done."
      STDOUT.puts "-------------------------------------"
    end
  end
end
