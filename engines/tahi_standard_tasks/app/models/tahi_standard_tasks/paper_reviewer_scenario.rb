module TahiStandardTasks
  # Provides a template context for PaperReviewerTask
  class PaperReviewerScenario < TemplateContext
    context :journal,                  source: [:object, :paper, :journal]
    context :manuscript, type: :paper, source: [:object, :paper]
    context :invitation,               source: :object
  end
end
