# Provides a template context for Invitations
class InvitationContext < TemplateContext
  whitelist :due_in_days, :state
end
