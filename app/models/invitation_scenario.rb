class InvitationScenario < TemplateContext
  subcontext :journal,                  source: [:object, :paper, :journal]
  subcontext :manuscript, type: :paper, source: [:object, :paper]
  subcontext :invitation,               source: :object
  subcontext :inviter,    type: :user,  source: [:object, :inviter]
  subcontext :invitee,    type: :user,  source: [:object, :invitee]
end
