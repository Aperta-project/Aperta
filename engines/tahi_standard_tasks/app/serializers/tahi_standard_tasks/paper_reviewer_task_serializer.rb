module TahiStandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :reviewers, include: true, root: :users, serializer: UserSerializer
    has_many :invitations, inclue: true

    def reviewers
      object.paper.reviewers.includes :affiliations
    end
  end
end
