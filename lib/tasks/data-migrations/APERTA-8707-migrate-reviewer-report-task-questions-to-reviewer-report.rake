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
              question.owner = reviewer_report
              answer.owner = reviewer_report
              answer.save(validate: false)
            end
            unless question.owner_id_changed?
              question.owner = ReviewerReport.where(
                task: task,
                user: task.reviewer,
                decision: nil
              ).first_or_create!
            end
            question.save
          end
        end
        if Task.where(type: relevant_tasks).map(&:nested_questions).flatten.empty?
          STDOUT.puts("Nested Question migration for Reviewer Report completed")
        else
          STDOUT.puts("Migration Failed, not all nested questions were moved")
        end
      end

      task reviewer_report_to_reviewer_report_task: :environment do
        ReviewerReport.find_each do |report|
          task = report.task
          report.nested_questions.each do |question|
            question.nested_question_answers.find_each do |answer|
              answer.owner = task
              answer.save(validate: false)
            end
            question.update(owner: task)
          end
          report.destroy
        end
      end
    end
  end
end
