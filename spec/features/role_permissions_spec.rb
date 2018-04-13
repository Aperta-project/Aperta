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
require 'support/pages/dashboard_page'

feature 'journal admin role', js: true do
  let(:user) { create :user }
  let!(:journal) { create :journal, :with_roles_and_permissions }
  let!(:another_journal) { create :journal, :with_roles_and_permissions }

  let(:dashboard) { DashboardPage.new }

  context 'non-admin user with journal admin assignment' do
    before do
      assign_journal_role(journal, user, :admin)
      login_as(user, scope: :user)
      visit "/"
    end

    scenario 'the user can see admin-y links' do
      # the user can see the admin link on the dashboard
      expect(dashboard.admin_link).to be_present

      # the user can view the admin page for a journal
      admin_page = dashboard.visit_admin
      expect(admin_page).to have_journal_name(journal.name)
      admin_page.visit_journal(journal)
    end
  end

  context 'non-admin user without journal admin role' do
    before do
      login_as(user, scope: :user)
      visit "/"
    end

    scenario 'the user does not see the admin link on the dashboard' do
      expect(dashboard).to have_no_admin_link
    end
  end
end
