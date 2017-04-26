class CardPermissionSerializer < ActiveModel::Serializer
  attributes :id, :filter_by_card_id, :permission_action
  has_many :roles, include: true, embed: :id

  # Action is a word that rails doesn't like, so work around it
  def permission_action
    object.action
  end
end
