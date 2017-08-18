# Provides a template context for Invitations
class InvitationContext < TemplateContext
  def self.merge_fields
    [{ name: :state },
     { name: :due_in_days }]
  end

  whitelist :state

  def due_in_days
    nil
  end
end
