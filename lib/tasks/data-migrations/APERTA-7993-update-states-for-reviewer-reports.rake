namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7993 Update states for ReviewerReports
    DESC
    task update_states_for_reviewer_reports: :environment do
      # Keep a running count of reports
      count = 0
      # Keep a list of skipped ids
      skipped_ids = []

      # Print out our total reports
      total_reports = ReviewerReport.where(state: nil).count
      puts "Updating state for #{total_reports} ReviewerReports"

      # Find any blank status
      ReviewerReport.where(state: nil).find_each do |report|
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

        # All reports here have blank state columns
        # AASM will fill in 'invitation_pending' when they are hydrated
        # If we have an accepted invitation, we can start going through the
        # flow to update the report state.
        report.accept_invitation! if report.invitation_accepted?

        # With an accepted invitation, the report is marked 'pending'. Usually
        # finishing the task will mark it complete. Here we will check to see
        # if there are any nested question answers and mark the review complete
        # accordingly.
        if report.review_pending?
          # Get the newest answered qustion for this report
          answer = Answer.where(owner: report)
                         .select { |a| !a.value.blank? }
                         .max_by(&:updated_at)

          # If there is an answer, try to mark reviews as complete
          # If there is no answer to an accepted invitation, those stay in the
          # 'review_pending' state
          if answer
            # If our decision is a draft (not decided yet) and the task body
            # had 'submitted' set, we can mark this complete by submitting the
            # review
            if report.decision.draft? && report.task.body['submitted']
              report.submit!
              report.submitted_at = answer.updated_at
            end

            # We are for a decision that has been made. Since it has answers,
            # we mark it complete
            unless report.decision.draft?
              report.submit!
              report.submitted_at = answer.updated_at
            end
          end
        end

        puts "Updating: ReviewerReport[#{report.id}, state: #{report.aasm.current_state}, submitted_at: #{report.submitted_at}]"
        # Save the report
        report.save!
      end

      puts "Updated #{count} reports, Skipped #{skipped_ids.count} #{skipped_ids}"

      # Check the remaining blanks if any
      blank_state = ReviewerReport
        .where(state: nil)
        .where.not(id: skipped_ids)

      if blank_state.any?
        ids = blank_state.map(&:id)
        raise "Blank state found for Reports: #{ids}"
      end
    end
  end
end
