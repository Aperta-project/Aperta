module TahiStandardTasks
  class RegisterDecisionScenario < PaperScenario
    def reviews
      return unless manuscript_object.draft_decision
      @reviews = []
      reviews_with_num = []
      reviews_without_num = []
      manuscript_object.draft_decision.reviewer_reports.each do |rr|
        context = ReviewerReportContext.new(rr)
        context.reviewer_number.present? ? reviews_with_num << context : reviews_without_num << context
      end
      @reviews = reviews_with_num.sort_by(&:reviewer_number) + reviews_without_num.sort_by(&:submitted_at)
    end
  end
end
