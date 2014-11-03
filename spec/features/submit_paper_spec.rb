require 'spec_helper'

feature "Submitting a paper", js: true, selenium: true do
  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  let(:author) { create :user }

  let :paper do
    FactoryGirl.create :paper, user: author
  end

  before do
    paper.tasks.update_all(completed: true)
  end

  scenario "Author submits a paper" do
    foo = EditPaperPage.visit(paper)
    submit_paper_overlay = foo.submit
    expect(submit_paper_overlay).to have_paper_title

    dashboard_page = submit_paper_overlay.submit
    expect(dashboard_page).to have_no_application_error
    expect(dashboard_page).to have_submission(paper.title)

    paper_page = dashboard_page.view_submitted_paper paper
    expect(paper_page).to have_paper_title(paper.title)
  end
end
