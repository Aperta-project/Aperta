module TahiStandardTasks
  class PaperReviewerTaskSerializer < ::TaskSerializer
    embed :ids
    has_many :reviewers
    attributes :invitation_template, :invitee_role
    has_one :card_version, embed: :id, include: true

    def reviewers
      object.paper.reviewers.includes :affiliations
    end

    def invitation_template
      object.invitation_template
    end
  end
end
