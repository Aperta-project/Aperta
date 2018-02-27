class DiscussionTopicSerializer < AuthzSerializer
  attributes :id, :paper_id, :title, :created_at

  has_many :participants, embed: :ids, include: true, root: 'users'
  has_many :discussion_participants, embed: :ids, include: true
  has_many :discussion_replies, embed: :ids, include: true

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
