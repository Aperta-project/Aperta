class PaperReviewerTaskSerializer < ::TaskSerializer
  embed :ids
  has_many :reviewers
  attributes :invitee_role

  def reviewers
    object.paper.reviewers.includes :affiliations
  end
end
