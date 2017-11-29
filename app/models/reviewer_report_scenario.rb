class ReviewerReportScenario < TemplateContext
  wraps ReviewerReport
  subcontext :journal,                            source: [:object, :paper, :journal]
  subcontext :manuscript, type: :paper,           source: [:object, :paper]
  subcontext :review,     type: :reviewer_report, source: :object
  subcontext :reviewer,   type: :user,            source: [:object, :user]
end
