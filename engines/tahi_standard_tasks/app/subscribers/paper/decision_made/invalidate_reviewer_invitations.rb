# Rescinds any in-flight reviewer invitations when a decision is made.
# Reviewers are also unassigned from the paper, but that
# process is owned by Paper::DecisionMade::UnassignReviewers
# which lives in the main app.
class Paper::DecisionMade::InvalidateReviewerInvitations
  def self.call(_event_name, event_data)
    paper = event_data[:record]

    invitations = Invitation.joins(:task).where(
      'tasks.paper_id' => paper.id,
      'tasks.type' => 'TahiStandardTasks::PaperReviewerTask',
      'invitations.state' => 'invited')

    invitations.each(&:rescind!)
  end
end
