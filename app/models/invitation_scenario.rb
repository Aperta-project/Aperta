class InvitationScenario < TemplateContext
  context :journal,    source: 'object.paper.journal'
  context :paper,      as: :manuscript
  context :invitation, source: 'object'
end
