class InvitationScenario < TemplateContext
  subcontext :journal,    source: [:object, :paper, :journal]
  subcontext :manuscript, type: :paper
  subcontext :invitation, source: :object
end
