class PendingInvitationFragment < PageFragment
  def reject
    element_text = element.text
    click_button 'no'
    synchronize_no_content! element_text
  end
end
