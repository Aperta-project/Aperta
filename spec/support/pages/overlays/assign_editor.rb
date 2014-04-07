class AssignEditorOverlay < CardOverlay
  def paper_editor=(name)
    select_from_chosen name, class: 'editor-select'
  end

  def paper_editor
    find('.editor-select').text
  end
end
