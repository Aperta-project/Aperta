# Shows up on the PaperReviewerTask
class InviteReviewersOverlay < CardOverlay
  text_assertions :reviewer, '.invitation-item-full-name'

  def paper_reviewers=(reviewers)
    reviewers.each do |reviewer|
      # Find thru auto-suggest
      fill_in "invitation-recipient", with: reviewer.email
      find(".auto-suggest-item", text: "#{reviewer.full_name} [#{reviewer.email}]").click

      # Invite
      find('.compose-invite-button').click
      find('.send-invitation-button').click

      # Make sure we see they were invited
      expect(page).to have_css('.active-invitations')
      expect(page).to have_css('.active-invitations .invitation-item-full-name', text: reviewer.full_name)
    end
  end

  def invite_new_reviewer(email)
    fill_in "invitation-recipient", with: email
    find('.compose-invite-button').click
    find('.send-invitation-button').click
    find('.active-invitations .invitation-item-full-name', text: email)
  end

  def paper_reviewers
    all('.invitation-item-full-name').map(&:text)
  end

  def has_reviewers?(*reviewers)
    reviewers.all? do |reviewer|
      has_reviewer?(reviewer)
    end
  end

  def total_invitations_count(count)
    page.has_css? '.invitation-item', count: count
  end

  def active_invitations_count(count)
    page.has_css? '.active-invitations .invitation-item', count: count
  end

  def expired_invitations_count(count)
    page.has_css? '.expired-invitations .invitation-item', count: count
  end
end
