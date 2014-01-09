class AssignEditorOverlay < CardOverlay
  def paper_editor=(name)
    select_from_chosen name, from: 'Editor'
  end

  def paper_editor
    find('#task_paper_role_attributes_user_id_chosen').text
  end
end
