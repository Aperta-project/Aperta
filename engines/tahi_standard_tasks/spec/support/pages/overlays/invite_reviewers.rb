class InviteReviewersOverlay < CardOverlay
  text_assertions :reviewer, '.invitee-full-name'
  def paper_reviewers=(reviewers)
    reviewers.each do |reviewer|
      session.has_no_css?('#delayedSave', visible: false)
      pick_from_select2_single(reviewer.username, reviewer.email, class: 'reviewer-select2')
      if find('.select2-chosen').text == reviewer.email
        find('.invite-reviewer-button').click
      else
        raise 'Did not find any matching reviewers'
      end
    end
  end

  def paper_reviewers
    all('.invitee-full-name').map &:text
  end

  def has_reviewers?(*reviewers)
    reviewers.all? do |reviewer|
      has_reviewer? reviewer.full_name
    end
  end

  def remove_all_paper_reviewers!
    all('a.select2-search-choice-close').each &:click
  end

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
