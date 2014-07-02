class PaperReviewerTaskSerializer < TaskSerializer
  embed :ids
  has_many :journal_reviewers, serializer: UserSerializer, include: true, root: :users
  has_many :reviewers, serializer: UserSerializer, include: true, root: :users

  def reviewers
    object.reviewers.includes(:affiliations)
  end

  def journal_reviewers
    object.journal_reviewers.includes(:affiliations)
  end
end
