# Provides a template context for Invitations
class InvitationContext < TemplateContext
  def self.merge_field_definitions
    [{ name: :state },
     { name: :due_in_days }]
  end

  whitelist :state

  def due_in_days
    nil
  end
end
