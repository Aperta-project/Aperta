require 'spec_helper'

feature "Account creation" do
  scenario "User can create an account" do
    sign_up_page = SignUpPage.visit
    dashboard_page = sign_up_page.sign_up_as first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      affiliation: 'Universität Zürich'
    expect(dashboard_page.header).to have_content 'Welcome'
  end
end
