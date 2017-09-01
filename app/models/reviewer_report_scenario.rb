# Provides a template context for ReviewerReport
class ReviewerReportScenario < TemplateScenario
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

  def journal
    JournalContext.new(reviewer_report.paper.journal)
  end

  def manuscript
    PaperContext.new(reviewer_report.paper)
  end

  private

  def reviewer_report
    @object
  end
end
