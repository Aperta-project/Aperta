require 'rails_helper'
require 'support/pages/sign_in_page'

feature "Devise account creation", js: true do
  scenario "User can create an account" do
    sign_up_page = SignUpPage.visit
    dashboard_page = sign_up_page.sign_up_as(
      username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password'
    )
    expect(page).to have_current_path(root_path)
    expect(dashboard_page).to have_welcome_message("Hi, Albert")
  end
end

feature "Devise signing in", js: true do
  let!(:user) { create :user }
  scenario "User can sign in to & out of the site using their email address" do
    sign_in_page = SignInPage.visit
    dashboard_page = sign_in_page.sign_in user
    expect(page).to have_current_path(root_path)
    dashboard_page.sign_out
    expect(page).to have_current_path(new_user_session_path)
  end

  scenario "User can sign in to & out of the site using their username" do
    sign_in_page = SignInPage.visit
    dashboard_page = sign_in_page.sign_in user, user.username
    expect(page).to have_current_path(root_path)
    dashboard_page.sign_out
    expect(page).to have_current_path(new_user_session_path)
  end
end

feature "Devise redirect", js: true do
  let!(:user) { FactoryGirl.create :user }
  scenario "User is redirected after login" do
    visit '/profile'
    fill_in('Login', with: user.username)
    fill_in('Password', with: 'password')
    click_on "Sign in"
    expect(page).to have_css('#profile')
    expect(page).to have_current_path('/profile')
  end
end

feature "Devise resetting password", js: true do
  let!(:user) { create :user }
  scenario "User can reset their password" do
    SignInPage.visit
    click_link('Forgot your password?')
    fill_in('user_email', with: user.email)
    click_button('Send reset instructions')
    expect(page).to have_content 'You will receive an email with instructions about how to reset your password in a few minutes.'
  end
end
