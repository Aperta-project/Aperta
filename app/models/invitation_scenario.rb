class InvitationScenario < PaperScenario
  def invitation
    @invitation ||= InvitationContext.new(invitation_object)
  end

  private

  def manuscript_object
    invitation_object.paper
  end

  def invitation_object
    @object
  end
end
