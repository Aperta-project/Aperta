class CommentLookSerializer < AuthzSerializer
  attributes :id

  has_one :comment, embed: :id
  has_one :paper, embed: :id
  has_one :task, embed: :id, polymorphic: true
  has_one :user, embed: :id

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
