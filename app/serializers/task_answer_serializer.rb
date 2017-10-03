class TaskAnswerSerializer < TaskSerializer
  attribute :not_ready
  has_many :answers, embed: :ids, include: true, root: :answers

  def not_ready
    true
  end
end
