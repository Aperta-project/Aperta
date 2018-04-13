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
require 'support/pages/paper_page'
require 'support/pages/paper_workflow_page'

feature 'Withdrawing a paper', js: true do
  let!(:paper) do
    FactoryGirl.create(
      :paper,
      :with_integration_journal,
      :with_creator
    )
  end
  let(:journal_admin) { FactoryGirl.create(:user) }
  let(:creator) { paper.creator }
  let(:dashboard_page) { DashboardPage.new }
  let(:paper_page) { PaperPage.new }
  let(:workflow_page) { PaperWorkflowPage.new }

  before do
    assign_journal_role(paper.journal, journal_admin, :admin)
  end

  scenario 'User withdrawing their own paper' do
    login_as(creator, scope: :user)

    visit "/papers/#{paper.to_param}"
    paper_page.withdraw_paper

    visit '/'
    dashboard_page.expect_paper_to_be_withdrawn(paper)

    logout
    login_as(journal_admin, scope: :user)

    visit "/papers/#{paper.id}/workflow"
    expect(page).to have_css('.withdrawal-banner')
    workflow_page.view_recent_activity
    workflow_page.expect_activity_item_with_text('Manuscript was withdrawn')
  end

  scenario 'Staff reactivating a withdrawn paper' do
    paper.withdraw! 'Because the sky is green and the sea is purple.', creator

    login_as(journal_admin, scope: :user)

    visit "/papers/#{paper.to_param}"

    page.find('.withdrawal-banner .reactivate').click
    expect(page).to_not have_css('.withdrawal-banner')

    expect(paper.reload.withdrawn?).to be(false)

    visit "/papers/#{paper.to_param}/workflow"
    workflow_page.view_recent_activity
    workflow_page.expect_activity_item_with_text('Manuscript was reactivated')
  end
end
