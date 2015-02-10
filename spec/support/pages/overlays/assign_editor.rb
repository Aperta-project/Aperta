class AssignEditorOverlay < CardOverlay
  def paper_editor=(user)
    pick_from_select2_single user.username, user.email, class: 'editor-select2'
  end

  def paper_editor
    find('.editor-select2').text
  end

  def has_editor?(editor)
    expect(page).to have_css('.editor-select2', text: editor.email)
  end
end
