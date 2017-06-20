module TahiStandardTasks
  # Provides a template context for PaperReviewerTask
  class PaperReviewerScenario < TemplateContext
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
