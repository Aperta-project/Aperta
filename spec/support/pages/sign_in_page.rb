class SignInPage < Page
  path :new_user_session

  def sign_in_as(user)
    fill_in "Email", with: user.email
    fill_in "Password", with: 'password'
    click_on "Sign in"
    DashboardPage.new
  end
end
