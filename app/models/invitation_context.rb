class InvitationContext < TemplateContext
  whitelist :state

  def due_in_days
    @object.paper.review_duration_period
  end

  def decline_reason_html_safe
    @object.decline_reason.try(:html_safe)
  end

  def reviewer_suggestions_html_safe
    @object.reviewer_suggestions.try(:html_safe)
  end
end
