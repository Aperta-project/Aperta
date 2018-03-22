class NotificationSerializer < AuthzSerializer
  attributes :id, :paper_id, :user_id, :target_type, :target_id, :parent_type, :parent_id

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
