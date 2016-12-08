# Adds reviewer numbers to reviewer report tasks that were completed at some point
module ReviewerNumberMigration
  def self.backfill_reviewer_numbers
    log_strings = []
    paper_ids_with_reports.each do |id|
      log_strings << update_report_tasks(id)
    end

    all_logs = log_strings.flatten
    puts all_logs
    puts "@@@@@@@@@@@@ Added #{all_logs.count} reviewer numbers"
  end

  def self.paper_ids_with_reports
    # there are 205 of these in production
    TahiStandardTasks::ReviewerReportTask.distinct(:paper_id).pluck(:paper_id)
  end

  def self.completed_report_task_titles(paper_id)
    Activity.where(subject_type: "Paper", subject_id: paper_id, activity_key: "task.completed")
      .where("message LIKE 'Review by%'")
      .order(:created_at)
      .map(&:message)
      .map { |m| m.match(/(.*) card was marked/)[1] }
      .uniq
  end

  def self.completed_report_tasks(paper_id)
    TahiStandardTasks::ReviewerReportTask
      .where(title: completed_report_task_titles(paper_id), paper_id: paper_id)
      .where("(body -> 'reviewer_number') IS NULL")
  end

  def self.update_report_tasks(paper_id)
    logs = []
    completed_report_tasks(paper_id).each_with_index do |task, index|
      task.set_reviewer_number(index + 1)
      task.save!
      log_string =  "===========================> Added reviewer number to task #{task.id} on paper #{paper_id}: #{task.title}"
      logs << log_string
    end
    logs
  end
end

namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7810: Adds reviewer numbers to ReviewerReportTasks based on when they
      were first completed.
    DESC
    task backfill_reviewer_numbers: :environment do
      ReviewerNumberMigration.backfill_reviewer_numbers
    end
  end
end
