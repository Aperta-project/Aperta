class AdminEditRolePage < Page
  def editor?
    find('#role_editor').checked?
  end

  def reviewer?
    find('#role_reviewer').checked?
  end

  def cancel
    click_on 'Cancel'
    AdminRolesPage.new
  end
end
