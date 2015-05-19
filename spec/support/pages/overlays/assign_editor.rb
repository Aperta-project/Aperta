class AssignEditorOverlay < CardOverlay
  def paper_editor=(user)
    select2 user.email, css: '.editor-select2', search: true
  end

  def paper_editor
    find('.editor-select2').text
  end

  def has_editor?(editor)
    expect(page).to have_css('.editor-select2', text: editor.email)
  end
end
