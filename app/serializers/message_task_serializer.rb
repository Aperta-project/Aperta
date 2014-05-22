class MessageTaskSerializer < TaskSerializer
  embed :ids
  attributes :unread_comments_count
  has_many :comments, include: true
  has_many :participants, serializer: UserSerializer, include: true, root: :users

  def unread_comments_count
    comment_ids = object.comments.pluck(:id)
    read_count = PublicActivity::Activity.where(trackable_id: comment_ids,
                                                trackable_type: 'Comment',
                                                key: 'comment.read',
                                                owner_id: current_user.id).count
    total_count = comment_ids.count - read_count
  end
end
