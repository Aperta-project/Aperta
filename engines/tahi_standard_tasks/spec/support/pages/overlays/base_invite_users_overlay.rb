# PaperReviewerTask and PaperEditorTask both inherit from this overlay
class BaseInviteUsersOverlay < CardOverlay
  text_assertions :invitee, '.invitation-item-full-name'

  def invited_users=(users)
    users.each do |invitee|
      # Find thru auto-suggest
      fill_in "invitation-recipient", with: invitee.email
      find(".auto-suggest-item", text: "#{invitee.full_name} <#{invitee.email}>").click

      # Invite
      find('.invitation-email-entry-button').click
      find('.invitation-save-button').click
      row = find('.active-invitations .invitation-item-header', text: invitee.full_name)
      row.find('.invite-send').click

      # Make sure we see they were invited
      expect(page).to have_css('.active-invitations')
      expect(page).to have_css('.active-invitations .invitation-item-full-name', text: invitee.full_name)
    end
  end

  def invite_new_user(email)
    fill_in "invitation-recipient", with: email
    find('.invitation-email-entry-button').click
    find('.invitation-save-button').click
    row = find('.active-invitations .invitation-item-header', text: email)
    row.find('.invite-send').click
  end

  def has_invitees?(*invitees)
    invitees.all? do |user|
      has_invitee?(user)
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
