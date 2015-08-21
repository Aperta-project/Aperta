class InviteReviewersOverlay < CardOverlay
  text_assertions :reviewer, '.invitee-full-name'

  def paper_reviewers=(reviewers)
    reviewers.each do |reviewer|
      # Find thru auto-suggest
      fill_in "Reviewer", with: reviewer.full_name
      find(".auto-suggest-item", text: "#{reviewer.full_name} [#{reviewer.email}]").click

      # Invite
      find('.compose-invite-button').click
      find('.invite-reviewer-button').click

      # Make sure we see they were invited
      find('table .active-invitations .invitee-full-name', text: reviewer.full_name)
    end
  end

  def invite_new_reviewer(email)
    fill_in "Reviewer", with: email
    find('.compose-invite-button').click
    find('.invite-reviewer-button').click
    find('table .active-invitations .invitee-full-name', text: email)
  end

  def paper_reviewers
    all('.invitee-full-name').map &:text
  end

  def has_reviewers?(*reviewers)
    reviewers.all? do |reviewer|
      has_reviewer?(reviewer)
    end
  end

  def total_invitations_count(count)
    page.has_css? '.invitees .invitation', count: count
  end

  def active_invitations_count(count)
    page.has_css? '.invitees .active-invitations .invitation', count: count
  end

  def expired_invitations_count(count)
    page.has_css? '.invitees .expired-invitations .invitation', count: count
  end
end
