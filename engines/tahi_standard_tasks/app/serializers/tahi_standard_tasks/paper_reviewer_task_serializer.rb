module TahiStandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :reviewers, include: true, root: :users, serializer: UserSerializer

    def reviewers
      object.paper.reviewers.includes :affiliations
    end
  end
end
