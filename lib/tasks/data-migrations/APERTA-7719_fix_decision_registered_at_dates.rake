namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7719 Use data from the activity feed to fix `registered_at` dates
      for decisions.
    DESC
    task fix_decision_registered_at_dates: :environment do
      # A hash which relates decision verdicts to their expected activity
      # messages. Used for testing if individual decisions and activities match.
      decision_messages = {
        reject: [
          "Reject was sent to author",
          "A decision was made: Reject"
        ],
        invite_full_submission: [
          "A decision was made: Invite Full Submission",
          "Invite Full Submission was sent to author"
        ],
        minor_revision: [
          "A decision was made: Minor Revision",
          "Minor Revision was sent to author"
        ],
        major_revision: [
          "A decision was made: Major Revision",
          "Major Revision was sent to author"
        ],
        accept: [
          "Accept was sent to author",
          "A decision was made: Accept"
        ]
      }.with_indifferent_access

      Paper.find_each do |paper|
        decision_activities = paper.activities
                                   .where(activity_key: "decision.made")
                                   .reorder(created_at: :asc)
        completed_decisions = paper.decisions.completed
                                   .reorder(created_at: :asc)

        # If there are more decision activities than decisions or vice versa,
        # bail. Something has gone wrong and this migration isn't equipped to
        # handle it.
        unless decision_activities.count == completed_decisions.count
          raise <<-ERR.strip_heredoc
            The decision activity feed count (#{decision_activities.count}) did
            not match the decision count (#{completed_decisions.count})
            on paper, #{paper.id}.
          ERR
        end

        # Assume that the nth decision on a paper matches up with the nth
        # decision activity.
        completed_decisions.zip(decision_activities) do |decision, activity|
          # For sanity, test that the activity message matches up with the
          # decision's verdict. If it doesn't, bail because something has gone
          # wrong and this migration isn't equipped to handle it.
          expected_messages = decision_messages.fetch(decision.verdict, [])
          unless expected_messages.include?(activity.message)
            raise <<-ERR.strip_heredoc
              '#{decision.verdict}' on paper #{paper.id} does not match the
              corresponding activity message, '#{activity.message}'.
            ERR
          end

          # If we got to here, we know with a high confidence that the activity
          # and decision represent the same event. So use the activity's
          # accurate time record to set the decision's registered_at
          decision.update! registered_at: activity.created_at
        end
      end
    end
  end
end
