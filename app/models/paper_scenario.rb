class PaperScenario < TemplateContext
  context :journal
  context :paper, as: :manuscript, source: 'object'
end
