module TahiStandardTasks
  # Provides a template context for RegisterDecisionTasks
  class RegisterDecisionScenario < TemplateContext
    def manuscript
      @manuscript ||= PaperContext.new(paper)
    end

    def journal
      @journal ||= JournalContext.new(paper.journal)
    end

    def reviews
      if paper.draft_decision
        @reviews ||= paper.draft_decision.reviewer_reports.map do |rr|
          ReviewerReportContext.new(rr)
        end
        @reviews.sort_by(&:reviewer_number)
      end
    end

    private

    def paper
      @object
    end
  end
end
