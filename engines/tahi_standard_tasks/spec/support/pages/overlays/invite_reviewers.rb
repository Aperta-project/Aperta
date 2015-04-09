class InviteReviewersOverlay < CardOverlay
  def total_invitations
    all '.invitation'
  end

  def active_invitations
    all '.invitees .active-invitations .invitation'
  end

  def expired_invitations
    all '.invitees .expired-invitations .invitation'
  end
end
