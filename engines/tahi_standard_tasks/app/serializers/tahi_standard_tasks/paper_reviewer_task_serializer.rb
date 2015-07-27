module TahiStandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :reviewers, include: true, root: :users, serializer: UserSerializer
    has_many :invitations, include: true
    attributes :letter

    def reviewers
      object.paper.reviewers.includes :affiliations
    end

    def letter
      object.invite_letter.to_json
    end
  end
end
