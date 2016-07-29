class PendingInvitationFragment < PageFragment
  def accept(button_text='Accept')
    click_button button_text
  end

  def reject(button_text='Decline')
    click_button button_text
    expect(session).to have_content("You've successfully declined this invitation")
  end
end
