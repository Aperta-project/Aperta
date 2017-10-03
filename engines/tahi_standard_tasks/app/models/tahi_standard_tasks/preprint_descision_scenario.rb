module TahiStandardTasks
  # Provides a template context for PreprintDecisionTasks
  class PreprintDecisionScenario < PaperScenario
    def self.merge_field_definitions
      [{ name: :manuscript, context: PaperContext },
       { name: :journal, context: JournalContext }]
    end
  end
end
