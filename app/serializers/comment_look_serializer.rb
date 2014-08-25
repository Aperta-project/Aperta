class CommentLookSerializer < ActiveModel::Serializer
  attributes :id, :read_at
  has_one :comment, embed: :id
end
