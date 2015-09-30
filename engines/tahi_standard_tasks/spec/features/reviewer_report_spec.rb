require 'rails_helper'

feature "Reviewer filling out their reviewer report", js: true do
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper_with_phases, journal: journal }
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }
  let!(:reviewer1) { create :user }
  let!(:reviewer2) { create :user }
  let!(:reviewer3) { create :user }

  before do
    assign_journal_role journal, editor, :editor
    paper.paper_roles.create user: editor, role: PaperRole::EDITOR
    task.participants << editor

    login_as(editor, scope: :user)
    visit "/"

    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer1]
    end
    manuscript_page.sign_out
  end

  scenario "A reviewer can fill out their own Reviewer Report, submit it, and see a readonly view of their responses" do
    login_as(reviewer1, scope: :user)
    visit "/"

    dashboard_page = DashboardPage.new
    dashboard_page.accept_invitation_for_paper(paper)
    visit "/papers/#{paper.id}"
    paper_page = PaperPage.new

    overlay = paper_page.view_card("Review by #{reviewer1.full_name}", ReviewerReportOverlay)
    overlay.fill_in_report "competing_interests" => "I have no competing interests with this work."
    overlay.submit_report
    overlay.confirm_submit_report

    expect(page).to have_selector(".answer-text", text: "I have no competing interests with this work.")
  end
end
