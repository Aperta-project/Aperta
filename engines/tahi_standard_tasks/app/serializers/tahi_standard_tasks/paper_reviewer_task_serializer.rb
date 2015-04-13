module TahiStandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :reviewers, include: true, root: :users, serializer: UserSerializer
    has_many :decisions, embed: :ids, include: true, serializer: DecisionSerializer

    def reviewers
      object.paper.reviewers.includes :affiliations
    end

    def decisions
      object.paper.decisions
    end
  end
end
