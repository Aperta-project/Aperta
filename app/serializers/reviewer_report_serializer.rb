# Serializes ReviewerReports.  Sends down its card content
# as nested questions
class ReviewerReportSerializer < ActiveModel::Serializer
  include CardContentShim

  attributes :id,
    :decision_id,
    :user_id,
    :created_at,
    :status,
    :status_datetime,
    :due_at,
    :originally_due_at,
    :revision
  has_one :task

  def due_at
    object.due_at if FeatureFlag[:REVIEW_DUE_DATE]
  end

  def status
    object.computed_status
  end

  def status_datetime
    object.computed_datetime
  end
end
