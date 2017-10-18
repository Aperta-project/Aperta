module TahiStandardTasks
  class RegisterDecisionScenario < PaperScenario
    def reviews
      return unless manuscript_object.draft_decision
      @reviews ||= manuscript_object.draft_decision.reviewer_reports.where(state: 'submitted').map do |rr|
        ReviewerReportContext.new(rr)
      end
      reviews_with_num, reviews_without_num = @reviews.partition(&:reviewer_number)
      @reviews = reviews_with_num.sort_by(&:reviewer_number) + reviews_without_num.sort_by(&:submitted_at)
    end
  end
end
