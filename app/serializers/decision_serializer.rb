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

  def unauthorized_result
    {
      id:            object.try(:id),
      draft:         object.try(:draft?),
      registered_at: object.try(:registered_at),
      major_version: object.try(:major_version),
      minor_version: object.try(:minor_version)
    }
  end
end
