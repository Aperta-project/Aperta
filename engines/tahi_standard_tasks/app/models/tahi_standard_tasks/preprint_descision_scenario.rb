module TahiStandardTasks
  # Provides a template context for PreprintDecisionTasks
  class PreprintDecisionScenario < TemplateContext

    def manuscript
      @manuscript ||= PaperContext.new(paper)
    end

    def journal
      @journal ||= JournalContext.new(paper.journal)
    end

    private

    def paper
      @object
    end
  end
end
