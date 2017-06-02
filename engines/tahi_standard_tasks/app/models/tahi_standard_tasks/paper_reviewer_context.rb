module TahiStandardTasks
  # Provides a template context for PaperReviewerTask
  class PaperReviewerContext < Liquid::Drop
    attr_accessor :manuscript, :journal, :invitation

    def initialize(invitation)
      @invitation = InvitationContext.new(invitation)
      @journal = JournalContext.new(invitation.paper.journal)
      @manuscript = PaperContext.new(invitation.paper)
    end
  end
end
