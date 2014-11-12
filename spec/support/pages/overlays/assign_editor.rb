class AssignEditorOverlay < CardOverlay
  def paper_editor=(user)
    pick_from_select2_single user.username, user.full_name, class: 'editor-select2'
  end

  def paper_editor
    find('.editor-select2').text
  end

  def has_editor?(editor)
    expect(page).to have_css('.editor-select2', text: editor.full_name)
  end
end
