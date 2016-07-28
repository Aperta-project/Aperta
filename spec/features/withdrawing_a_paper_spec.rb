require 'rails_helper'

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

    visit "/papers/#{paper.id}"
    paper_page.withdraw_paper

    visit '/'
    dashboard_page.expect_paper_to_be_withdrawn(paper)

    logout
    login_as(journal_admin, scope: :user)

    visit "/papers/#{paper.id}/workflow"
    workflow_page.view_recent_activity
    workflow_page.expect_activity_item_with_text('Manuscript was withdrawn')
  end

  scenario 'Staff reactivating a withdrawn paper' do
    paper.withdraw! 'Because the sky is green and the sea is purple.', creator

    login_as(journal_admin, scope: :user)

    visit "/papers/#{paper.id}"

    page.find('.withdrawal-banner .reactivate').click
    expect(page).to_not have_css('.withdrawal-banner')

    expect(paper.reload.withdrawn?).to be(false)

    visit "/papers/#{paper.id}/workflow"
    workflow_page.view_recent_activity
    workflow_page.expect_activity_item_with_text('Manuscript was reactivated')
  end
end
