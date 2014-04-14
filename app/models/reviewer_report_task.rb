class ReviewerReportTask < Task
  PERMITTED_ATTRIBUTES = [{paper_review_attributes: [:body, :id]}]

  title 'Reviewer Report'
  role 'reviewer'

  has_one :paper_review, foreign_key: 'task_id'

  accepts_nested_attributes_for :paper_review

  def assignees
    journal.reviewers
  end
end
