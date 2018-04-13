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
require 'support/pages/sign_in_page'

feature "Editor Discussion", js: true do
  let(:journal) { create :journal, :with_roles_and_permissions }
  let(:journal_admin) { create :user }
  let(:paper) { create :paper, journal: journal }
  let(:task) { create :editors_discussion_task, paper: paper }
  let(:dashboard_page) { DashboardPage.new }

  before do
    assign_journal_role journal, journal_admin, :admin
    task.add_participant(journal_admin)

    SignInPage.visit.sign_in journal_admin
  end

  scenario "journal admin can see the 'Editor Discussion' card" do
    visit "/papers/#{paper.id}/tasks/#{task.id}"
    expect(find('.overlay-body-title')).to have_content "Editor Discussion"
  end
end
