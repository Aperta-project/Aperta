class AssignAdminOverlay < CardOverlay
  text_assertions :admin, '.admin-select2', ->(email){ email }

  def admin=(user)
    pick_from_select2_single user.email, user.email, class: 'admin-select2'
  end
end
