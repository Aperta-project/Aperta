class CommentLookSerializer < ActiveModel::Serializer
  attributes :id, :read_at
  has_one :comment, embed: :id
  has_one :user, embed: :id
  has_one :task, embed: :id
end
