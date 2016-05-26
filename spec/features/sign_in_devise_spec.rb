require 'rails_helper'

feature "Devise signing in", js: true do
  let!(:user) { create :user }
  scenario "User can sign in to & out of the site using their email address" do
    sign_in_page = SignInPage.visit
    dashboard_page = sign_in_page.sign_in user
    expect(page.current_path).to eq(root_path)
    dashboard_page.sign_out
    expect(page.current_path).to eq new_user_session_path
  end

  scenario "User can sign in to & out of the site using their username" do
    sign_in_page = SignInPage.visit
    dashboard_page = sign_in_page.sign_in user, user.username
    expect(page.current_path).to eq(root_path)
    dashboard_page.sign_out
    expect(page.current_path).to eq new_user_session_path
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

