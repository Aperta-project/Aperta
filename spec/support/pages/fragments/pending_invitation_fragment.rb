class PendingInvitationFragment < PageFragment
  def accept
    element_text = element.text
    click_button 'yes'
    session.has_content? element_text
  end

  def reject
    element_text = element.text
    click_button 'no'
    session.has_content? element_text
  end
end
