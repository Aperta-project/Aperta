class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks

  validates :task, :body, presence: true

  #TODO: remove this method - deprecated
  def self.create_with_comment_look(task, params)
    new(params).tap do |new_comment|
      commenter_id = params[:commenter_id].to_i

      task.participants.each do |participant|
        new_comment.comment_looks.new(user_id: participant.id) unless participant.id == commenter_id
      end

      new_comment.save!
    end
  end

  def created_by?(user)
    commenter_id == user.id
  end

  def meta_type
    self.class.name
  end

  def has_meta?
    true
  end

  def meta_id
    id
  end

  private

  def notifier_payload
    { task_id: task.id, paper_id: task.paper.id }
  end
end
