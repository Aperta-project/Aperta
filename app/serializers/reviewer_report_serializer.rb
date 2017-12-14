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
    :revision,
    :active_admin_edit?

  has_one :due_datetime, embed: :ids, include: true
  has_one :task
  has_many :scheduled_events, embed: :ids, include: true
  has_many :admin_edits, embed: :ids, include: true

  def due_at
    object.due_at
  end

  def due_at_id
    object.due_datetime.id if object.due_datetime.present?
  end

  def status
    object.status
  end

  def status_datetime
    object.datetime
  end
end
