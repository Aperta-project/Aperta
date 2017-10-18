module TahiStandardTasks
  class RegisterDecisionScenario < PaperScenario
    def reviews
      return unless manuscript_object.draft_decision
      @reviews ||= manuscript_object.draft_decision.reviewer_reports.map do |rr|
        ReviewerReportContext.new(rr)
      end
      reviews_with_num, reviews_without_num = @reviews.partition(&:reviewer_number)
      @reviews = reviews_with_num.sort_by(&:reviewer_number) + reviews_without_num.sort_by { |r| r.submitted_at || 0 }
    end
  end
end
