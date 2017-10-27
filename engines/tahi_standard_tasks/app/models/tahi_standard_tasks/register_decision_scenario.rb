module TahiStandardTasks
  class RegisterDecisionScenario < TemplateContext
    context :journal
    context :paper,   as: :manuscript, source: "@object"
    context :reviews, many: true

    def reviews
      return unless @object.draft_decision
      @reviews ||= @object.draft_decision.reviewer_reports.submitted.map do |rr|
        ReviewerReportContext.new(rr)
      end
      reviews_with_num, reviews_without_num = @reviews.partition(&:reviewer_number)
      @reviews = reviews_with_num.sort_by(&:reviewer_number) + reviews_without_num.sort_by { |r| r.submitted_at || 0 }
    end
  end
end
