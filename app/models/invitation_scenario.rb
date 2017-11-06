class InvitationScenario < TemplateContext
  context :journal,    source: [:object, :paper, :journal]
  context :manuscript, type: :paper
  context :invitation, source: :object
end
