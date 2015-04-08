module TahiStandardTasks
  class ReviseTaskSerializer < ::TaskSerializer
    has_many :decisions, embed: :ids, include: true, serializer: DecisionSerializer

    def decisions
      paper.decisions
    end
  end
end
