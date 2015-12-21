require 'rails_helper'

feature "Editor Discussion", js: true do
  let(:journal) { create :journal }
  let(:journal_admin) { create :user }
  let(:paper) { create :paper, journal: journal }
  let(:task) { create :editors_discussion_task, paper: paper }
  let(:dashboard_page) { DashboardPage.new  }

  before do
    assign_journal_role journal, journal_admin, :admin
    task.participants << journal_admin

    SignInPage.visit.sign_in journal_admin
  end

  scenario "journal admin can see the 'Editor Discussion' card" do
    visit "/papers/#{paper.id}/tasks/#{task.id}"
    expect(find('.overlay-body-title')).to have_content "Editor Discussion"
  end
end
