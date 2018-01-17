class InvitationScenario < TemplateContext
  subcontext :journal,                  source: [:object, :paper, :journal]
  subcontext :manuscript, type: :paper, source: [:object, :paper]
  subcontext :invitation,               source: :object
  subcontext :inviter,    type: :user
  subcontext :invitee,    type: :user

  def invitee_name_or_email
    @object.invitee.try(:full_name) || @object.email
  end
end
