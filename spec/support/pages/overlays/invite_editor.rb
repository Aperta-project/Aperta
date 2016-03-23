class InviteEditorOverlay < CardOverlay
  def paper_editors=(editors)
    editors.each do |editor|
      # Find thru auto-suggest
      fill_in "Academic Editor", with: editor.full_name
      find(".auto-suggest-item", text: "#{editor.full_name} [#{editor.email}]").click

      # Invite
      find('.compose-invite-button').click
      find('.invite-editor-button').click

      # Make sure we see they were invited
      find('table .active-invitations .invitee-full-name', text: editor.full_name)
    end
  end

  def paper_editor
    find('.editor-select2').text
  end

  def has_editor?(editor)
    expect(page).to have_css('.invitation', text: editor.full_name)
  end
end
