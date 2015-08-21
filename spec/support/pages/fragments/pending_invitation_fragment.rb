class PendingInvitationFragment < PageFragment
  def accept
    element_text = element.text
    click_button 'yes'
    synchronize_no_content! element_text
  end

  def reject
    element_text = element.text
    click_button 'no'
    synchronize_no_content! element_text
  end
end
