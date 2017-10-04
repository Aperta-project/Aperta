class TaskAnswerSerializer < TaskSerializer
  attributes :not_ready, :completed_proxy
  has_many :answers, embed: :ids, include: true, root: :answers

  def not_ready
    true
  end

  def completed_proxy
    object.completed
  end
end
