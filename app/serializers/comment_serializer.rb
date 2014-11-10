class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at

  has_one :task, embed: :id, polymorphic: true
  has_one :commenter, serializer: UserSerializer, include: true, root: :users, embed: :id
  has_one :comment_look, include: true, embed: :id

  def comment_look
    object.comment_looks.where('read_at is null').find_by(user: scoped_user)
  end

  private

  def scoped_user
    scope.presence || options[:user]
  end
end
