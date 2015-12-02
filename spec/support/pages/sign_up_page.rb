class SignUpPage < Page
  path :new_user_registration

  def sign_up_as options
    user = FactoryGirl.build(:user)
    fill_in "Username", with: options.fetch(:username){ user.username }
    fill_in "First name", with: options.fetch(:first_name){ user.first_name }
    fill_in "Last name", with: options.fetch(:last_name){ user.last_name }
    fill_in "Email", with: options.fetch(:email){ user.email }
    fill_in "Password", with: options.fetch(:password){ "password" }
    fill_in "Password confirmation", with: options.fetch(:password){ "password" }
    click_on "Sign up"

    DashboardPage.new
  end

  def sign_in_as user
    fill_in "Login", with: user.username
    fill_in "Password", with: "password"
  end
end
