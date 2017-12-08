class PaperScenario < TemplateContext
  wraps Paper
  subcontext :journal
  subcontext :manuscript, type: :paper, source: :object
end
