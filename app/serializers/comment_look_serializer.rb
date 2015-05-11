class CommentLookSerializer < ActiveModel::Serializer
  attributes :id, :comment_id, :user_id, :paper_id

  has_one :task, embed: :id, polymorphic: true

  def paper_id
    object.phase.paper_id
  end
end
