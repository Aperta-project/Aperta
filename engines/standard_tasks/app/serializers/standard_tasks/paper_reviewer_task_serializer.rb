module StandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :possible_reviewers, serializer: UserSerializer, include: true, root: :users
    has_many :reviewers, serializer: UserSerializer, include: true, root: :users

    def reviewers
      object.paper.reviewers.includes(:affiliations)
    end

    def possible_reviewers
      object.paper.possible_reviewers.includes(:affiliations)
    end
  end
end
