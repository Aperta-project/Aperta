# Provides a template context for ReviewerReport
class ReviewerReportScenario < TemplateContext
  def review
    ReviewerReportContext.new(reviewer_report)
  end

  def reviewer
    UserContext.new(reviewer_report.user)
  end

  def journal
    JournalContext.new(reviewer_report.paper.journal)
  end

  def paper
    PaperContext.new(reviewer_report.paper)
  end

  private

  def reviewer_report
    @object
  end
end
