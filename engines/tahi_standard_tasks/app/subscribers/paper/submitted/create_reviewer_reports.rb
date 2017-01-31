# After a resubmission, we need to generate a new
# reviewer report for any existing review tasks
class Paper::Submitted::CreateReviewerReports
  REVIEWER_SPECIFIC_TASKS = ["TahiStandardTasks::FrontMatterReviewerReportTask",
                             "TahiStandardTasks::ReviewerReportTask"]

  def self.call(_, event_data)
    paper = event_data[:record]

    reviewer_tasks = paper.tasks.where(type: REVIEWER_SPECIFIC_TASKS)
    reviewer_tasks.each do |task|
      ReviewerReport.create!(
        task: task,
        decision: paper.draft_decision,
        user: task.reviewer
      )
    end
  end
end
