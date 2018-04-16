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
require 'support/pages/admin_dashboard_page'

feature "Search Users on Admin Dashboard", js: true do
  let(:user) { create :user, :site_admin, first_name: "Test", last_name: "User", username: "testuser" }
  let!(:journal) { create :journal, :with_roles_and_permissions }

  before do
    create :user, first_name: "Bob", last_name: "Merlyn", username: 'shadow_missing2010'
    create :user, first_name: "Jim", last_name: "Bobit", username: 'jim'
    create :user, first_name: "Sam", last_name: "Smith", username: 'bobby'
    create :user, first_name: "Jane", last_name: "Doe", username: 'janny'

    login_as(user, scope: :user)
    visit "/"
  end

  let(:admin_page) { AdminDashboardPage.visit }

  scenario "Searching users returns a list of users" do
    search_results = admin_page.search_results("bob")

    expect(search_results.length).to eq(3)
    expect(search_results).to match_array(
      [{ first_name: "Bob", last_name: "Merlyn", username: 'shadow_missing2010' },
       { first_name: "Jim", last_name: "Bobit", username: 'jim' },
       { first_name: "Sam", last_name: "Smith", username: 'bobby' }])
  end
end
