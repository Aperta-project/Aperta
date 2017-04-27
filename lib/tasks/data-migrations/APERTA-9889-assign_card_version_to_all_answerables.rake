require Rails.root.join("lib/tasks/card_loading/support/card_associator.rb")

namespace :data do
  namespace :migrate do
    desc <<-DESC
      Assign a CardVersion relationship for all Answerable models.
    DESC
    task assign_card_version_to_all_answerables: [:environment, "cards:load"] do
      STDOUT.puts "-------------------------------------"

      answerable_klasses = [
        Author,
        GroupAuthor,
        ReviewerReport,
        TahiStandardTasks::Funder,
        TahiStandardTasks::ReviewerRecommendation,
        ::Task.descendants - [CustomCardTask]
      ].flatten

      answerable_klasses.each do |answerable_klass|
        STDOUT.puts "Associating #{answerable_klass} ..."
        associator = CardAssociator.new(answerable_klass)
        associator.process
        associator.assert_all_associated!
        STDOUT.puts "Done."
      end

      STDOUT.puts "-------------------------------------"
    end
  end
end
