require 'rails_helper'

feature "CAS account creation" do
  scenario "User can create account for cas" do
    sign_in_page = SignInPage.visit
    expect(sign_in_page).to have_link('Create CAS Account')
  end

  scenario "User can login with cas" do
    sign_in_page = SignInPage.visit
    expect(sign_in_page).to have_link('Sign in with CAS')
  end
end
