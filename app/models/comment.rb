class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks, dependent: :destroy

  validates :task, :body, presence: true

  def created_by?(user)
    commenter_id == user.id
  end

  private

  def notifier_payload
    { id: task.id, paper_id: task.paper.id }
  end

  def records_to_load
    [{type: task.class.base_class.name.underscore, id: task.id}]
  end
end
