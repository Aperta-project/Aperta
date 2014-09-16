class AssignAdminOverlay < CardOverlay
  text_assertions :admin, '.chosen-assignee.chosen-container'

  def admin=(name)
    select_from_chosen name, class: 'chosen-assignee'
  end
end
