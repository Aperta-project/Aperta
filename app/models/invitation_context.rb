class InvitationContext < TemplateContext
  whitelist :state

  def due_in_days
    @object.paper.review_duration_period
  end
end
