class JournalTaskType < ActiveRecord::Base
  belongs_to :journal, inverse_of: :journal_task_types

  validates :old_role, :title, presence: true

  def required_permission
    return if required_permission_action && required_permission_applies_to
    Permission.where(
      action: required_permission_action,
      applies_to: required_permission_applies_to
    ).first
  end
end
