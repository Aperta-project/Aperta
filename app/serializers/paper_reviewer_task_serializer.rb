class PaperReviewerTaskSerializer < TaskSerializer
  embed :ids
  has_many :journal_reviewers, serializer: UserSerializer, include: true, root: :users
  has_many :reviewers, serializer: UserSerializer, include: true, root: :users
end
