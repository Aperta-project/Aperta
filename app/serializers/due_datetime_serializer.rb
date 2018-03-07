class DueDatetimeSerializer < AuthzSerializer
  attributes :id, :due_at, :reviewer_report_id

  has_many :scheduled_events, embed: :ids, include: true

  # I'm glossing over the fact that this is a polymorphic relationship
  # for now, these only belong to reviewer_reports, so we're just
  # going to trick ember into thinking it's a non-polymorphic relationship
  def reviewer_report_id
    object.due_id
  end
end
