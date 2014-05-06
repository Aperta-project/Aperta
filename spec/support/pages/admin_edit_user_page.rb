class AdminEditUserPage < Page

  def initialize
    expect(page).to have_css '.edit_member_link.active'
    super
  end

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
