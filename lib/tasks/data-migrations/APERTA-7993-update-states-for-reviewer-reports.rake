namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7993 Update blank ReviewerReport statuses
    DESC
    task update_blank_status_for_reviewer_reports: :environment do
      # Keep a running count of reports
      count = 0
      # Keep a list of skipped ids
      skipped_ids = []

      # Query to find candidates for updating
      blank_status_query = 'status_datetime IS NULL OR status IS NULL'

      # Print out our total reports
      total_reports = ReviewerReport.where(blank_status_query).count
      puts "Updating status fields for #{total_reports} ReviewerReports"

      # Find any blank status
      ReviewerReport.where(blank_status_query).find_each do |report|
        # Some reports in production had no user id. These cannot be
        # automatically updated and will have to be skipped.
        unless report.user_id
          puts "Warning: Skipping ReviewerReport #{report.id}"
          puts "         There is no associated reviewer on this report"
          skipped_ids.push(report.id)
          next
        end

        # All reports after this point get some kind of update
        count += 1

        # Get the corresponding invitaiton if there is one
        invitation = report.invitation
        report.state = 'invitation_pending'

        if invitation
          # Update status based on invitation state
          report.state = 'review_pending' if invitation.state == "accepted"
        end

        # Update any of the status/datetime fields
        report.update_invitation_status

        # With an accepted invitation, the report is marked 'pending'. Usually
        # finishing the task will mark it complete. Here we will check to see
        # if there are any nested question answers and mark the review complete
        # accordingly.
        if report.review_pending?
          # Get the newest answered qustion for this report
          answer = NestedQuestionAnswer.where(owner: report)
                                       .select { |a| !a.value.blank? }
                                       .max_by(&:updated_at)

          # If there is an answer, try to mark reviews as complete
          if answer
            # Look if there is a draft (current) decision
            # And see if our reviewer report is for that decision
            if paper.draft_decision && report.decision == report.paper.draft_decision && report.task.body['submitted']
              # If we are for the current decision, look on tasks body for submitted?
              report.status = 'complete'
            end
            if report.decision != report.paper.draft_decision
              report.status = 'complete'
              report.status_datetime = answer.updated_at
            end
          end
        end

        puts "Updating: ReviewerReport[#{report.id}, status: #{report.status}, status_datetime: #{report.status_datetime}]"
        # Save the status
        report.save!
      end

      puts "Updated #{count} reports, Skipped #{skipped_ids.count} #{skipped_ids}"

      # Check the remaining blanks if any
      blank_statuses = ReviewerReport
        .where(status: nil)
        .where.not(id: skipped_ids)

      if blank_statuses.any?
        ids = blank_statuses.map(&:id)
        raise "Blank status found for Reports: #{ids}"
      end

      # Check that any nil dates are 'not_invited
      blank_datetime_states = ['invitation_pending', 'not_invited']
      incorrect_status =
        ReviewerReport.where(status_datetime: nil)
                      .where.not(id: skipped_ids)
                      .select { |report| !blank_datetime_states.include? report.status }

      if incorrect_status.any?
        ids = incorrect_status.map(&:id)
        raise "Incorrect status with nil dates for Reports: #{ids}"
      end
    end
  end
end
