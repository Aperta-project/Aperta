module Declaration
  class TaskSerializer < ::TaskSerializer
    has_many :surveys, embed: :ids, include: true
  end
end
