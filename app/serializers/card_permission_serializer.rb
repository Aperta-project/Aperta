class CardPermissionSerializer < AuthzSerializer
  attributes :id, :filter_by_card_id, :permission_action

  has_many :admin_journal_roles, embed: :ids

  # Action is a word that rails doesn't like, so work around it
  def permission_action
    object.action
  end

  def admin_journal_roles
    object.roles
  end

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
