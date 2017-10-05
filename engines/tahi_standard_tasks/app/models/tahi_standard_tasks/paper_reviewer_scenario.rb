module TahiStandardTasks
  # Provides a template context for PaperReviewerTask
  class PaperReviewerScenario < InvitationScenario
    def self.complex_merge_fields
      [{ name: :invitation, context: InvitationContext },
       { name: :journal, context: JournalContext },
       { name: :manuscript, context: PaperContext }]
    end
  end
end
