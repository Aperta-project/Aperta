class DashboardPage < Page
  def header
    page.find 'header'
  end

  def sign_out
    click_on 'Sign out'
  end
end
