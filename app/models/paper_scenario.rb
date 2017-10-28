class PaperScenario < TemplateContext
  context :journal
  context :manuscript, type: :paper, source: 'object'
end
