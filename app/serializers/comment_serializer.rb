class CommentSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :body, :created_at

  has_one :task, embed: :id, polymorphic: true
  has_one :commenter, serializer: UserSerializer, include: true, root: :users
  has_one :comment_look, include: true, embed: :ids

  def comment_look
    if (defined? current_user) && current_user
      object.comment_looks.where(user: current_user, read_at: nil).first
    end
  end
end
