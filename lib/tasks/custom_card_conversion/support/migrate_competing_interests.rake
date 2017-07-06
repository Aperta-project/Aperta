require Rails.root.join('lib/tasks/custom_card_conversion/support/add_card_to_all_journals.rb')
require Rails.root.join('lib/tasks/custom_card_conversion/support/custom_task_migrator.rb')

namespace :card_conversions do
  desc 'Convert system cards to card_config cards'

  task :competing_interests do
    desc 'Convert tasks, answers, and templates related to the Competing Interests card'
    card_name = 'Competing Interests'

    adder = AddCardToAllJournals.new('competing_interests.xml', card_name)
    adder.from_configuration_file

    migrator = CustomTaskMigrator.new('TahiStandardTasks::CompetingInterestsTask', card_name)
    migrator.migrate
  end
end
