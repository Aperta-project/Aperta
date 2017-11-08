class PreprintDecisionScenario < TemplateContext
  context :journal
  context :manuscript, type: :paper, source: :object
end
