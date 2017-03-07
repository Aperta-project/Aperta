namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7993 Update blank ReviewerReport statuses
    DESC
    task update_blank_status_for_reviewer_reports: :environment do
      # Keep a running count of reports
      count = 0
      # Find any blank status
      ReviewerReport.where('status_datetime IS NULL OR status IS NULL').find_each do |report|
        count += 1
        invitation = report.invitation

        # If there is no invitation for this report (and associated decision),
        # then the reviewer has not been invited to this round.
        unless invitation
          report.update!(status: 'not_invited')
          next
        end

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

        # Save the status
        report.save!
      end

      puts "Updated #{count} reports"

      # Check the remaining blanks if any
      num_empty_status = ReviewerReport.where(status: nil).count
      if num_empty_status > 0
        ids = ReviewerReport.where(status: nil).pluck(:id)
        raise "Empty ReviewerReport statuses found #{ids}"
      end

      # Check that any nil dates are 'not_invited
      incorrect_status = ReviewerReport.where(status_datetime: nil)
                                       .select { |report| report.status != 'not_invited' }

      unless incorrect_status.empty?
        ids = incorrect_status.map(&:id)
        raise "Incorrect status with nil dates for Reports: #{ids}"
      end
    end
  end
end
