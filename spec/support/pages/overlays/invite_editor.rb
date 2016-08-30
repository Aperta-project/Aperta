class InviteEditorOverlay < CardOverlay
  def paper_editors=(editors)
    editors.each do |editor|
      create_invite_for(editor, send_now: true)
    end
  end

  # editor might just be a string
  def create_invite_for(editor, send_now: false)
    if editor.full_name
      fill_in "invitation-recipient", with: editor.full_name
      find(".auto-suggest-item", text: "#{editor.full_name} [#{editor.email}]").click
    else
      fill_in "invitation-recipient", with: editor
    end

    invitee_text = editor.full_name || editor
    # Invite
    find('.invitation-email-entry-button').click
    find('.invitation-save-button').click
    if send_now
      row = find('.active-invitations .invitation-item-header', text: invitee_text)
      row.find('.invite-send').click
    end

    # Make sure we see they were invited
    expect(page).to have_css('.active-invitations .invitation-item-full-name', text: invitee_text)
  end

  def paper_editor
    find('.editor-select2').text
  end

  def has_invite_for?(editor)
    has_css?('.active-invitations .invitation-item', text: editor.full_name)
  end
end
