# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'support/pages/sign_in_page'
require 'support/pages/sign_up_page'

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

feature "SUBMISSIONS_DISABLED flag", js: true do
  let!(:user) { create :user }
  scenario "User sees flag flash message" do
    FactoryGirl.create(:feature_flag, name: "DISABLE_SUBMISSIONS")
    sign_in_page = SignInPage.visit
    dashboard_page = sign_in_page.sign_in user
    expect(page).to have_css('.disable-submissions-alert')
  end
end
