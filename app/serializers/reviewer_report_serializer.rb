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
    :revision
  has_one :task

  def status
    object.computed_status
  end

  def status_datetime
    object.computed_datetime
  end
end
