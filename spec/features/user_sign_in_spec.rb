require 'spec_helper'

feature "Account creation" do
  scenario "User can create an account" do
    sign_up_page = SignUpPage.visit
    dashboard_page = sign_up_page.sign_up_as username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      affiliation: 'Universität Zürich'

    expect(page.current_path).to eq(root_path)
    expect(dashboard_page.header).to have_content 'Welcome, Albert Einstein'
  end
end

feature "Signing in" do
  scenario "User can sign in to & out of the site using their email address" do
    user = User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'

    sign_in_page = SignInPage.visit
    dashboard_page = sign_in_page.sign_in user.email
    expect(page.current_path).to eq(root_path)
    dashboard_page.sign_out
    expect(page.current_path).to eq new_user_session_path
  end

  scenario "User can sign in to & out of the site using their username" do
    user = User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'

    sign_in_page = SignInPage.visit
    dashboard_page = sign_in_page.sign_in user.username
    expect(page.current_path).to eq(root_path)
    dashboard_page.sign_out
    expect(page.current_path).to eq new_user_session_path
  end
end
