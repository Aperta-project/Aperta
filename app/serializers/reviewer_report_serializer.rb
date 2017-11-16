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
    :due_at_id,
    :originally_due_at,
    :revision
  has_one :due_datetime, embed: :ids, include: true

  def due_at
    object.due_at if FeatureFlag[:REVIEW_DUE_DATE]
  end

  def due_at_id
    object.due_datetime.id if object.due_datetime.present? && FeatureFlag[:REVIEW_DUE_DATE]
  end

  def status
    object.status
  end

  def status_datetime
    object.datetime
  end
end
