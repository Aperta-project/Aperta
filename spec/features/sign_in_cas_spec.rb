require 'rails_helper'

feature "CAS account creation" do
  scenario "User can create account for cas" do
    sign_in_page = SignInPage.visit
    expect(sign_in_page).to have_link('Create an account')
  end

  scenario "User can login with cas" do
    sign_in_page = SignInPage.visit
    expect(sign_in_page).to have_link('Sign in with PLOS')
  end
end
