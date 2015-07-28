class InviteReviewersOverlay < CardOverlay
  text_assertions :reviewer, '.invitee-full-name'
  def paper_reviewers=(reviewers)
    reviewers.each do |reviewer|
      if find('.select2-chosen')
        select2 reviewer.email, css: '.reviewer-select2', search: true
      end
      page.has_no_css? '.select2-searching', visible: false
      page.has_css? '.select2-chosen', text: reviewer.email
      find('.compose-invite-button').click
      find('.invite-reviewer-button').click

      find('table .active-invitations .invitee-full-name', text: reviewer.full_name)
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
