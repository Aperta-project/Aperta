class CommentLookSerializer < ActiveModel::Serializer
  attributes :id, :read_at, :comment_id, :user_id, :paper_id

  has_one :task, embed: :id, polymorphic: true

  def paper_id
    object.phase.paper_id
  end
end
