namespace :data do
  namespace :migrate do
    desc 'Creates reviewer reports for every paper revision'
    task create_missing_reviewer_reports: :environment do
      relevant_tasks = ['TahiStandardTasks::ReviewerReportTask', 'TahiStandardTasks::FrontMatterReviewerReportTask']
      task_count = Task.where(type: relevant_tasks).count
      puts("Task count: #{task_count}")
      reviewer_report_count = 0

      # Loop through all relevant tasks
      Task.where(type: relevant_tasks).find_each do |task|
        reviewer = task.reviewer
        # Get the decisions associated with the paper, order ascending
        decisions = task.paper.decisions.order(id: :asc)
        # Drop decisions until we have one that the reviewer accepted
        decisions = decisions.drop_while { |d| !d.invitations.exists?(invitee: reviewer, state: 'accepted') }

        # Ensure that a ReviewerReport exists for the remaining decisions
        decisions.each do |d|
          ReviewerReport.find_or_create_by!(
            task: task,
            user: reviewer,
            decision: d
          ) do |r|
            reviewer_report_count += 1
            r.created_in_7993 = true
            if d.draft?
              version = "draft"
            else
              version = "v#{d.major_version}.#{d.minor_version}" unless d.draft?
            end
            puts "New ReviewerReport [User: #{reviewer.id}, Paper: #{task.paper.id},#{task.paper.doi} #{version}]"
          end
        end
      end
      puts "Created #{reviewer_report_count} reviews"
    end
    task remove_reviewer_reports_created_in_7993: :environment do
      report_count = ReviewerReport.where(created_in_7993: true).count
      puts("Removing #{report_count} reports")
      deleted_count = ReviewerReport.where(created_in_7993: true).delete_all
      unless deleted_count == report_count
        STDERR.puts("Removed only #{deleted_count} reports out of #{report_count}")
      end
    end
  end
end
