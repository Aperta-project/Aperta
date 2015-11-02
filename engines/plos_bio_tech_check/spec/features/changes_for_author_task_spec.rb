require 'rails_helper'

feature 'Changes For Author', js: true do
  let(:journal) { create :journal }
  let(:admin) { create :user, site_admin: true }
  let(:author) { create :user }
  let(:paper) { create :paper, :submitted, journal: journal, creator: author }
  let(:task) { create :changes_for_author_task, paper: paper }
  let(:dashboard) { DashboardPage.new }
  let(:manuscript_page) { dashboard.view_submitted_paper paper }

  before do
    assign_journal_role journal, admin, :admin
    task.participants << admin

    SignInPage.visit.sign_in admin
  end

  scenario "paper is editable but not submittable" do
    expect(manuscript_page).to have_no_css("#sidebar-submit-paper")

    manuscript_page.view_card task.title do |overlay|
      overlay.find("button#submit-tech-fix").click
    end
  end

end
