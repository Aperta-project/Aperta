class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :message_task, inverse_of: :comments, foreign_key: :task_id
  belongs_to :commenter, class_name: 'User'
  has_many :comment_looks

  after_create :create_comment_look

  private

  def create_comment_look
    message_task.participants.each do |participant|
      CommentLook.create! user_id: participant.id, comment_id: id
    end
  end

  def id_for_stream
    message_task.id
  end
end
