module StandardTasks
  class FigureTaskSerializer < TaskSerializer
    has_many :figures, embed: :ids, include: true
  end
end
