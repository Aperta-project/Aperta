class SignInPage < Page
  path :new_user_session

  def sign_in(username)
    fill_in "Login", with: username
    fill_in "Password", with: 'password'
    click_on "Sign in"
    DashboardPage.new
  end
end
