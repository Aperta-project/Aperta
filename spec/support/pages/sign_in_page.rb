class SignInPage < Page
  path :new_user_session

  def sign_in(user, signin_string=user.email)
    fill_in "Login", with: signin_string
    fill_in "Password", with: 'password'
    click_on "Sign in"
    synchronize_content! user.first_name
    DashboardPage.new
  end
end
