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

  def include_verdict?
    can_view_sensitive_details?
  end

  def include_letter?
    can_view_sensitive_details?
  end

  def include_author_response?
    can_view_sensitive_details?
  end

  private

  def can_view_sensitive_details?
    current_user.can?(:view, object.paper)
  end

  # Everyone can view basic info like draft status
  def can_view?
    true
  end
end
