module TahiStandardTasks
  class RegisterDecisionScenario < PaperScenario
    def reviews
      return unless manuscript_object.draft_decision
      @reviews ||= manuscript_object.draft_decision.reviewer_reports.map do |rr|
        ReviewerReportContext.new(rr)
      end
      @reviews.sort_by(&:reviewer_number)
    end
  end
end
