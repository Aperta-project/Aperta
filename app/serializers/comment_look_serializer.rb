class CommentLookSerializer < ActiveModel::Serializer
  attributes :id

  has_one :comment, embed: :id
  has_one :paper, embed: :id
  has_one :task, embed: :id, polymorphic: true
  has_one :user, embed: :id
end
