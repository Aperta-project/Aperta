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
    :originally_due_at,
    :revision
  has_one :due_datetime, embed: :ids, include: true

  def status
    object.status
  end

  def status_datetime
    object.datetime
  end
end
