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
