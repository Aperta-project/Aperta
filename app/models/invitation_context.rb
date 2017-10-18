class InvitationContext < TemplateContext
  whitelist :state

  def due_in_days
    nil
  end
end
