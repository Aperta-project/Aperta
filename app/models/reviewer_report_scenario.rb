class ReviewerReportScenario < TemplateContext
  context :journal,                          source: "@object.paper.journal"
  context :paper,           as: :manuscript, source: '@object.paper'
  context :reviewer_report, as: :review,     source: "@object"
  context :user,            as: :reviewer,   source: "@object.user"
end
