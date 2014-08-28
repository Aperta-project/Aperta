class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at

  has_one :task, polymorphic: true
  has_one :commenter, serializer: UserSerializer, include: true, root: :users, embed: :id
  has_one :comment_look, include: true, embed: :ids

  def comment_look
    if (defined? current_user) && current_user
      object.comment_looks.where(user: current_user).first
    end
  end
end
