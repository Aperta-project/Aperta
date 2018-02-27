class DiscussionReplySerializer < AuthzSerializer
  attributes :id, :discussion_topic_id, :body, :created_at

  has_one :replier, embed: :id, include: true, root: 'users'

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
