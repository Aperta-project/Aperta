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

require "rails_helper"
require 'support/authorization_spec_helper'
require 'support/pages/profile_page'

feature "Profile Page", js: true, vcr: {cassette_name: "ned_countries", record: :none} do
  include AuthorizationSpecHelper

  let(:user_role) { Role.where(name: Role::USER_ROLE).first_or_create! }
  let(:admin) { create :user, :site_admin }
  let(:profile_page) { ProfilePage.new }

  before do
    assign_user admin, to: admin, with_role: user_role
    login_as(admin, scope: :user)
    visit "/profile"
  end

  scenario "the page contains user's info if user is signed in" do
    expect(profile_page).to have_full_name(admin.full_name)
    expect(profile_page).to have_username(admin.username)
    expect(profile_page).to have_email(admin.email)
  end

  scenario "affiliation errors are handled" do
    profile_page.start_adding_affiliate
    profile_page.submit
    expect(page).to have_content(/can't be blank/i)
    expect(profile_page).to have_no_application_error
  end

  describe "canceling affiliation creation" do
    before do
      profile_page.start_adding_affiliate
    end

    it "hides the form" do
      expect(page).to have_css(".affiliations-form")
      find("a", text: "cancel").click
      expect(page).to have_no_css(".affiliations-form")
    end

    it "clears the form" do
      profile_page.fill_in_email("foo")
      find("a", text: "cancel").click
      find("a", text: "ADD NEW AFFILIATION").click
      expect(page).to have_no_content("foo")
    end
  end

  context "editing an affiliation" do
    let(:admin) { create :user, :with_affiliation, :site_admin }
    let(:affiliation) { admin.affiliations.last }
    let(:department) { 'new department' }

    scenario "user can edit an affiliation" do
      find('.fa-pencil').click
      find('[placeholder=Department]').send_keys(department)
      click_button('done')
      expect(page).to have_content(/#{department}/)
      expect(Affiliation.find(affiliation.id).department).to eq(department)
    end
  end

  context "removing an affiliation" do

    let(:admin) { create :user, :with_affiliation, :site_admin }
    let(:affiliation) { admin.affiliations.last }

    scenario "user can delete an affiliation", selenium: true do
      profile_page.remove_affiliate(affiliation.name)
      expect(page).to have_no_content(/#{affiliation.name}/)
    end
  end
end
