class InviteEditorOverlay < CardOverlay
  def paper_editor=(user)
    select2 user.email, css: '.editor-select2', search: true
    find('.compose-invite-button').click()
    find('.invite-editor-button').click()
  end

  def paper_editor
    find('.editor-select2').text
  end

  def has_editor?(editor)
    expect(page).to have_css('.invited-editor', text: editor.email)
  end
end
