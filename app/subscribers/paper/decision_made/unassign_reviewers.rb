# Removes reviewers from a paper when a decision is made.
# Note that reviewer invitations are also rescinded, but that
# process is owned by Paper::DecisionMade::InvalidateReviewerInvitations
# which lives in the tahi_standard_tasks engine
class Paper::DecisionMade::UnassignReviewers
  def self.call(_event_name, event_data)
    paper = event_data[:record]

    paper.reviewers.each do |reviewer|
      paper.unassign_reviewer reviewer
    end
  end
end
