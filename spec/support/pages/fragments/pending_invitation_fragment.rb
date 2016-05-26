class PendingInvitationFragment < PageFragment
  def accept(button_text='Accept')
    element_text = element.text
    click_button button_text
    session.has_content? element_text
  end

  def reject(button_text='Decline')
    element_text = element.text
    click_button button_text
    session.has_content? element_text
  end
end
