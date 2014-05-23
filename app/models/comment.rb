class Comment < ActiveRecord::Base
  include EventStreamNotifier

  include PublicActivity::Common

  validates :message_task, :body, presence: true

  belongs_to :message_task, inverse_of: :comments, foreign_key: :task_id
  belongs_to :commenter, class_name: 'User', inverse_of: :comments

  private

  def id_for_stream
    message_task.id
  end

  def task_payload
    { task_id: message_task.id, paper_id: message_task.paper.id }
  end
end
