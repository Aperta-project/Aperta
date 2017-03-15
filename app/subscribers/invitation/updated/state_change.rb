# Handle Invitation State Change events
class Invitation::Updated::StateChange
  def self.call(_event_name, event_data)
    invitation = event_data[:record]
    report = ReviewerReport.for_invitation(invitation)
    return unless report

    action = event_data[:action]
    if action == 'accepted'
      report.accept_invitation
    elsif action == 'rescinded'
      report.rescind_invitation
    end
  end
end
