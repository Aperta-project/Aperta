module TahiStandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :reviewers, serializer: UserSerializer, include: true, root: :users
    has_many :invitations, include: true

    def reviewers
      object.paper.reviewers.includes(:affiliations)
    end
  end
end
