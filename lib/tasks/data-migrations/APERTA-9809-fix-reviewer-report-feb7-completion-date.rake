namespace :data do
  namespace :migrate do
    namespace :reviewer_reports do
      desc 'Fix reviewer reports incorrectly marked complete on Feb 7, 2017 22:30-22:35'
      task fix_feb7_completion_dates: :environment do
        # Easy set differences
        require 'set'

        # We had a migration during this time that created Answers for
        # questions. This date was incorrectly used as a fallback date
        # for ReviewerReport completed_at
        start = DateTime.new(2017, 2, 7, 21, 20).utc
        finish = DateTime.new(2017, 2, 7, 21, 40).utc
        reports_to_process = ReviewerReport.where(["submitted_at between ? and ?", start, finish])
        total_reports = reports_to_process.count

        # These reports required us to use the decision's date
        decision_fallback_reports = []
        # These reports had no decision and no fall-back date
        not_fixed_reports = []

        puts "Processing #{total_reports} ReviewerReports"

        reports_to_process.group_by(&:task).each do |task, reports|
          # The task completion is recorded in the Activity feed.
          activity_message = "#{task.title} card was marked as complete"
          completions = Activity.where(message: activity_message,
                                       activity_key: 'task.completed',
                                       subject_type: 'Paper',
                                       subject_id: task.paper)

          # Try to update each report
          reports.each do |report|
            # Grab the latest activity indicating a comletion *before*
            # the associated decision was registered
            activity = completions
                         .where(["created_at < ?", report.decision.registered_at])
                         .order(created_at: :desc).first
            # Set the date if we found an activity
            date = activity.created_at if activity

            # Keep track of when we had to fall back on the decision date
            decision_fallback_reports << report unless date

            # Fall back to the decision date if no activity is found
            date ||= report.decision.registered_at

            # If we have a valid date, update the report, otherwise
            # add it to the list of ones not fixed
            if date
              report.update!(submitted_at: date)
              puts "Report #{report.id} new date: #{date}"
            else
              # No activity feed date or decision date
              not_fixed_reports << report
            end
          end
        end

        fallback_reports = Set.new(decision_fallback_reports) - Set.new(not_fixed_reports)
        updated_report_count = total_reports - fallback_reports.count - not_fixed_reports.count

        puts "Updated #{updated_report_count} reports"
        puts "Defaulted to decision completion date on #{fallback_reports.count} reports, ids: #{fallback_reports.map(&:id)}"
        puts "Unable to fix #{not_fixed_reports.count} reports, ids: #{not_fixed_reports.map(&:id)}"
      end
    end
  end
end
