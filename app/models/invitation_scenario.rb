class InvitationScenario < TemplateContext
  subcontext :journal,                  source: [:object, :paper, :journal]
  subcontext :manuscript, type: :paper, source: [:object, :paper]
  subcontext :invitation,               source: :object
  subcontext :inviter,    type: :user
  subcontext :invitee,    type: :user

  def reviewer_name
    @object.invitee.try(:full_name) || @object.email
  end
end
