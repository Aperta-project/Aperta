class DecisionSerializer < AuthzSerializer
  attributes :author_response,
             :created_at,
             :draft?,
             :id,
             :initial,
             :latest_registered?,
             :letter,
             :major_version,
             :minor_version,
             :registered_at,
             :rescindable?,
             :rescinded,
             :verdict

  has_many :invitations, embed: :ids, include: false
  has_many :attachments, include: true
  has_one :paper, embed: :id, include: true

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
