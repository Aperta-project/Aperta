namespace :one_off do
  desc "migrate existing activity records to hide reviewers from authors"
  task migrate_participations_activity_to_workflow: :environment do
    Activity.where(activity_key: ["participation.created", "participation.destroyed"]).update_all(feed_name: "workflow")
  end

  task remove_intelligible_question_from_reviewer_report: :environment do
    ActiveRecord::Base.transaction do
      task = TahiStandardTasks::ReviewerReportTask
      question = task.nested_questions.where(ident: 'intelligible').first
      deleted_position = question.position

      # child questions are *not* dependently destroyed (must do explicitly)
      # nested_question_answers are dependently destroyed by the nested_question
      question.children.destroy_all
      question.destroy!

      # after removing a top level question, the others have out-of-date position values
      top_level_questions = task.nested_questions.where(parent_id: nil).where('position > ?', deleted_position)
      top_level_questions.update_all('position = position - 1')
    end
  end

  desc "Create temporary Card models for testing purposes"
  task create_fake_cards_for_testing: :environment do
    puts "Creating fake cards ..."
    Card.transaction do
      25.times do |i|
        Card.create(name: "Card #{i}", journal: Journal.first)
      end
    end
  end
end
