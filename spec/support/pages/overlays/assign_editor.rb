class AssignEditorOverlay < CardOverlay
  def paper_editor=(name)
    select name, from: 'Editor'
  end

  def paper_editor
    selected_option = all('#task_paper_role_attributes_user_id option[selected]').first
    selected_option.try :text
  end
end
