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

        if invitation
          # Update status based on invitation state
          case invitation.state
          when "accepted"
            report.status = "pending"
            report.status_datetime = invitation.accepted_at
          when "declined"
            report.status = "invitation_declined"
            report.status_datetime = invitation.declined_at
          when "invited"
            report.status = "invitation_invited"
            report.status_datetime = invitation.invited_at
          when "rescinded"
            report.status = "invitation_rescinded"
            report.status_datetime = invitation.rescinded_at
          when "pending"
            report.status = "invitation_pending"
          end
        else
          # If there is no invitation for this report (and associated decision),
          # then the reviewer has not been invited to this round.
          report.status = "not_invited"
        end

        # With an accepted invitation, the report is marked 'pending'. Usually
        # finishing the task will mark it complete. Here we will check to see
        # if there are any nested question answers and mark the review complete
        # accordingly.
        if report.status == 'pending'
          # Get the newest answered qustion for this report
          answer = NestedQuestionAnswer.where(owner: report)
                                       .select { |a| !a.value.blank? }
                                       .max_by(&:updated_at)

          # If there is one, we can update the status to complete
          if answer
            report.status = 'complete'
            report.status_datetime = answer.updated_at
          end
        end

        puts "Updating: ReviewerReport[#{report.id}, status: #{report.status}, status_datetime: #{report.status_datetime}]"
        # Save the status
        report.update_columns(status: report.status, status_datetime: report.status_datetime)
        report.touch
        # Let me explain about the preceeding lines. For some unknown reason,
        # `report.save` didn't work reliably when run as part of a set of
        # migrations. ActiveRecord would notice the attributes were changed,
        # but keep them as `nil`
        #
        # This means that to get the data saved reliably, I needed to force it
        # in with `update_columns` instead.  The `report.touch` that follows
        # updates the `updated_at` time for the ReviewerReport.
      end

      puts "Updated #{count} reports, Skipped #{skipped_ids.count} #{skipped_ids}"

      # Check the remaining blanks if any
      ReviewerReport
        .where(status: nil)
        .where.not(id: skipped_ids)
        .find_each do |report|
        puts "Error: Blank Report [#{report.id}, status: #{report.status}, status_datetime: #{report.status_datetime}]"
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
