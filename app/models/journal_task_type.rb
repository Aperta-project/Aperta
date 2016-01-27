class JournalTaskType < ActiveRecord::Base
  belongs_to :journal, inverse_of: :journal_task_types
  validates :old_role, :title, presence: true
  after_create :log_created_record

  def required_permission
    return if required_permission_action.blank? ||
      required_permission_applies_to.blank?
    Permission.where(
      action: required_permission_action,
      applies_to: required_permission_applies_to
    ).first!
  end

  private

  def log_created_record
    Tahi.service_log.info "Created #{kind} JournalTaskType"
  end
end
