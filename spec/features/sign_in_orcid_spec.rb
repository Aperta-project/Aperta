require 'rails_helper'

feature "ORCID account creation" do
  scenario "User can login with cas", flaky: true do
    sign_in_page = SignInPage.visit
    expect(sign_in_page).to have_link('Sign in with ORCID')
  end
end
