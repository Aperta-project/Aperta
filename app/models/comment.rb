class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks

  validates :task, :body, presence: true

  after_create :create_comment_look

  private

  def create_comment_look
    return unless task.class.method_defined?(:participants)
    task.participants.each do |participant|
      next if participant.id == commenter.id
      CommentLook.create! user_id: participant.id, comment_id: id
    end
  end

  def id_for_stream
    task.id
  end

  def task_payload
    { task_id: task.id, paper_id: task.paper.id }
  end
end
