module TahiStandardTasks
  # Provides a template context for RegisterDecisionTasks
  class RegisterDecisionScenario < PaperScenario
    def self.merge_field_definitions
      [{ name: :manuscript, context: PaperContext },
       { name: :journal, context: JournalContext },
       { name: :reviews, context: ReviewerReportContext, many: true }]
    end

    def reviews
      return unless paper.draft_decision
      @reviews ||= paper.draft_decision.reviewer_reports.map do |rr|
        ReviewerReportContext.new(rr)
      end
      @reviews.sort_by(&:reviewer_number)
    end
  end
end
