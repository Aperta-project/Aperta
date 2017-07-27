Dir[Rails.root.join("lib/custom_card/**/*.rb")].each { |f| require f }

namespace :custom_card do
  desc 'Convert legacy tasks to custom card tasks'
  # example:  custom_card:convert_legacy_task[TahiStandardTasks::CompetingInterestsTask, Competing Interests]
  task :convert_legacy_task, [:task_name, :card_name] => [:environment, "cards:load"] do |_, args|
    task_name = args.fetch(:task_name)
    card_name = args.fetch(:card_name)
    STDOUT.puts "Migrating legacy task '#{task_name}' to custom card task '#{card_name}' ..."

    unless Card.find_by(name: card_name)
      abort "Unable to find an existing Card with name '#{card_name}'. Is there a configuration class for this card in lib/custom_card/configurations?"
    end

    migrator = CustomCard::Migrator.new(task_name, card_name)
    migrator.migrate
  end
end
