module StandardTasks
  class DataAvailabilityTaskSerializer < ::TaskSerializer
    has_many :questions, embed: :ids, include: true
  end
end
