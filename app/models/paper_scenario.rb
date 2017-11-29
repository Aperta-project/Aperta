class PaperScenario < TemplateContext
  def self.object_identifier
    'Paper'
  end

  wraps Paper
  subcontext :journal
  subcontext :manuscript, type: :paper, source: :object
end
