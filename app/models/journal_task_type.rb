class JournalTaskType < ActiveRecord::Base
  belongs_to :journal, inverse_of: :journal_task_types
  validates :role_hint, :title, presence: true
  after_create :log_created_record

  private

  def log_created_record
    Rails.logger.info "Created #{kind} JournalTaskType"
  end
end
