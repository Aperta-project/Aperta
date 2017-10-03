# Provides a template context for ReviewerReport
class ReviewerReportScenario < PaperScenario
  def self.complex_merge_fields
    [{ name: :review, context: ReviewerReportContext },
     { name: :reviewer, context: UserContext },
     { name: :journal, context: JournalContext },
     { name: :manuscript, context: PaperContext }]
  end

  def review
    ReviewerReportContext.new(reviewer_report)
  end

  def reviewer
    UserContext.new(reviewer_report.user)
  end

  private

  def reviewer_report
    @object
  end

  def paper
    reviewer_report.paper
  end
end
