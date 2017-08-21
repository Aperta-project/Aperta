module TahiStandardTasks
  # Provides a template context for RegisterDecisionTasks
  class RegisterDecisionScenario < TemplateScenario
    def self.merge_field_definitions
      [{ name: :manuscript, context: PaperContext },
       { name: :journal, context: JournalContext },
       { name: :reviews, context: ReviewerReportContext, many: true }]
    end

    def manuscript
      @manuscript ||= PaperContext.new(paper)
    end

    def journal
      @journal ||= JournalContext.new(paper.journal)
    end

    def reviews
      return unless paper.draft_decision
      @reviews ||= paper.draft_decision.reviewer_reports.map do |rr|
        ReviewerReportContext.new(rr)
      end
    end

    private

    def paper
      @object
    end
  end
end
