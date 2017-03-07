# Serializes ReviewerReports.  Sends down its card content
# as nested questions
class ReviewerReportSerializer < ActiveModel::Serializer
  include CardContentShim

  attributes :id,
    :decision_id,
    :user_id,
    :created_at,
    :status,
    :status_date,
    :revision
  has_one :task
end
