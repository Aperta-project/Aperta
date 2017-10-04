module TahiStandardTasks
  # Provides a template context for PreprintDecisionTasks
  class PreprintDecisionScenario < TemplateContext
    def self.merge_field_definitions
      [{ name: :manuscript, context: PaperContext },
       { name: :journal, context: JournalContext }]
    end

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
