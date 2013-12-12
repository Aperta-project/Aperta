class AdminEditUserPage < Page
  def admin?
    find('#user_admin').checked?
  end

  def set_admin
    check 'Admin'
    self
  end

  def save
    click_on 'Save'
    AdminUsersPage.new
  end
end
