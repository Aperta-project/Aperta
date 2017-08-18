module TahiStandardTasks
  # Provides a template context for PaperReviewerTask
  class PaperReviewerScenario < TemplateContext
    def self.merge_fields
      [{ name: :invitation, context: InvitationContext },
       { name: :journal, context: JournalContext },
       { name: :manuscript, context: PaperContext }]
    end

    def invitation
      @invitation ||= InvitationContext.new(@object)
    end

    def journal
      @journal ||= JournalContext.new(@object.paper.journal)
    end

    def manuscript
      @manuscript ||= PaperContext.new(@object.paper)
    end
  end
end
