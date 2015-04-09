class InviteReviewersOverlay < CardOverlay
  def invitations
    all('.invitees-table tr')
  end
end
