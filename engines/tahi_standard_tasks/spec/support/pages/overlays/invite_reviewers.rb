class InviteReviewersOverlay < CardOverlay
  def total_invitations
    all '.invitation'
  end

  def active_invitations
    all '.invitees-table .active-invitations .invitation'
  end
end
