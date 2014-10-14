class AssignEditorOverlay < CardOverlay
  def paper_editor=(name)
    select_from_chosen name, class: 'editor-select'
  end

  def paper_editor
    find('.editor-select').text
  end

  def has_editor?(editor)
    expect(page).to have_css('.editor-select', text: editor.full_name)
  end
end
