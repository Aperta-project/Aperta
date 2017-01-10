namespace :data do
  namespace :migrate do
    namespace :nested_questions do
      desc 'Sets the paper id on all nested question answers'
      task reviewer_report_task_to_reviewer_report: :environment do
        relevant_tasks = ['TahiStandardTasks::ReviewerReportTask', 'TahiStandardTasks::FrontMatterReviewerReportTask']
        Task.where(type: relevant_tasks).find_each do |task|
          task.nested_questions.each do |question|
            question.nested_question_answers.find_each do |answer|
              reviewer_report = ReviewerReport.where(
                                  task: task,
                                  user: task.reviewer,
                                  decision: answer.decision
                                ).first_or_create!
              STDOUT.puts("Setting Answer Owner for answer: #{answer.id} for reviewer_report: #{reviewer_report.id}")
              answer.owner_type = 'ReviewerReport'
              answer.owner = reviewer_report
              answer.save(validate: false)
            end
            question.update_column(:owner_type, ReviewerReport.name)
          end
        end
        STDOUT.puts("Nested Question migration for Reviewer Report completed")
      end

      task reviewer_report_to_reviewer_report_task: :environment do
      end
    end
  end
end
