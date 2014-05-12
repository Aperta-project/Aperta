class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :message_task, inverse_of: :comments, foreign_key: :task_id
  belongs_to :commenter, class_name: 'User'

  private

  def event_stream_payload
    { task_id: message_task.id, journal_id: message_task.journal.id }
  end
end
