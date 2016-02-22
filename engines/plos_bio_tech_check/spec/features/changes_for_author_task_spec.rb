require 'rails_helper'

feature 'Changes For Author', js: true do
  let(:journal) { create :journal, :with_roles_and_permissions }
  let(:author) { create :user }
  let(:paper) { create :paper, :submitted, journal: journal, creator: author }
  let(:task) { create :changes_for_author_task, paper: paper }
  let(:dashboard) { DashboardPage.new }
  let(:manuscript_page) { dashboard.view_submitted_paper paper }

  before do
    task.add_participant(author)

    SignInPage.visit.sign_in author
  end

  scenario "paper is editable but not submittable" do
    expect(manuscript_page).to have_no_css("#sidebar-submit-paper")

    t = manuscript_page.view_task task.title
    t.find("button#submit-tech-fix").click
  end

end
