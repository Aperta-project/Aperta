class CommentSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :body, :created_at, :has_been_read

  has_one :message_task
  has_one :commenter, serializer: UserSerializer, include: true, root: :users

  def has_been_read
    PublicActivity::Activity.where(trackable_id: object.id, key: 'comment.read', owner_id: current_user.id).exists?
  end
end
