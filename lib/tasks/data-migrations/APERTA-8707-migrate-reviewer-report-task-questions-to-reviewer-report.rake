namespace :data do
  namespace :migrate do
    namespace :nested_questions do
      desc 'Sets the paper id on all nested question answers'
      task reviewer_report_task_to_reviewer_report: :environment do
        Task.where(type: 'TahiStandardTasks::ReviewerReportTask').find_each do |task|
          reviewer_report = ReviewerReport.create(
            task: task,
            user: task.reviewer,
            decision: Decision.last #CHANGE THIS
          )
          task.reviewer_reports << reviewer_report
          task.save!
          task.nested_questions.each do |question|
            question.nested_question_answers.find_each do |answer|
              answer.owner_type = 'ReviewerReport'
              answer.owner = reviewer_report
              answer.save(validate: false)
            end
            question.update_column(:owner_type, ReviewerReport.name)
          end
        end
      end

      task reviewer_report_to_reviewer_report_task: :environment do
      end
    end
  end
end
