class PendingInvitationFragment < PageFragment
  def reject
    within element { click_button 'no' }
  end

end
