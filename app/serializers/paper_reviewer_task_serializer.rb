class PaperReviewerTaskSerializer < TaskSerializer
  embed :ids
  has_many :reviewers, serializer: UserSerializer, include: true, root: :users
end
