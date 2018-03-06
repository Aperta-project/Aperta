class JournalTaskType < ActiveRecord::Base
  include ViewableModel
  belongs_to :journal, inverse_of: :journal_task_types
  validates :role_hint, :title, presence: true
  after_create :log_created_record

  delegate_view_permission_to :journal

  private

  def log_created_record
    Rails.logger.info "Created #{kind} JournalTaskType"
  end
end
