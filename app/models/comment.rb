class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :message_task, inverse_of: :comments, foreign_key: :task_id
  belongs_to :commenter, class_name: 'User'

  def id_for_stream
    message_task.id
  end
end
