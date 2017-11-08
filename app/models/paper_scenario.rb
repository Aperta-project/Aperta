class PaperScenario < TemplateContext
  subcontext :journal
  subcontext :manuscript, type: :paper, source: :object
end
