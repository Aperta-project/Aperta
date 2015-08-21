module TahiStandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :reviewers, include: true, root: :users, serializer: UserSerializer
    attributes :invitation_template

    def reviewers
      object.paper.reviewers.includes :affiliations
    end

    def invitation_template
      object.invitation_template
    end
  end
end
