class AssignAdminOverlay < CardOverlay
  text_assertions :admin, '.admin-select2', ->(email){ email }

  def admin=(user)
    select2 user.email, css: '.admin-select2', search: true
  end
end
