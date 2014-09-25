class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task, inverse_of: :comments
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks, dependent: :destroy
  has_many :participants, through: :task

  validates :task, :body, presence: true

  def created_by?(user)
    commenter_id == user.id
  end

  def meta_type
    self.task.class.name.demodulize
  end

  def has_meta?
    true
  end

  def meta_id
    self.task.id
  end

  private

  def notifier_payload
    { task_id: task.id, paper_id: task.paper.id }
  end
end
