class ReviewerReportScenario < TemplateContext
  context :journal,                            source: 'object.paper.journal'
  context :manuscript, type: :paper,           source: 'object.paper'
  context :review,     type: :reviewer_report, source: 'object'
  context :reviewer,   type: :user,            source: 'object.user'
end
