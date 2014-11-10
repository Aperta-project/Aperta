class AssignAdminOverlay < CardOverlay
  text_assertions :admin, '.admin-select2 .select2-chosen'

  def admin=(user)
    pick_from_select2_single user.username, user.full_name, class: 'admin-select2'
  end
end
