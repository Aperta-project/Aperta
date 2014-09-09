class CommentLook < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :user
  belongs_to :comment

  private

  def notifier_payload
    { task_id: comment.task.id, paper_id: comment.task.paper.id }
  end
end
