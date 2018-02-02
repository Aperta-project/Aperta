module TahiStandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :reviewers
    attributes :invitee_role
    has_many :invitations, embed: :id, include: false

    def reviewers
      object.paper.reviewers.includes :affiliations
    end
  end
end
