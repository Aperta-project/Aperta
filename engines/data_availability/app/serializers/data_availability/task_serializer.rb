module DataAvailability
  class TaskSerializer < ::TaskSerializer
    has_many :questions, embed: :ids, include: true
  end
end
