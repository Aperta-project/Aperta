require 'spec_helper'

feature "Submitting a paper", js: true do
  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  let(:author) { create :user }

  let :paper do
    FactoryGirl.create :paper, user: author,
      authors: [{ first_name: 'Agnes', last_name: 'Stuart', affiliation: 'ABCMouse, Inc.', email: 'agnes@example.com' }]
  end

  before do
    paper.tasks.update_all(completed: true)
  end

  scenario "Author submits a paper" do
    submit_paper_page = EditPaperPage.visit(paper).submit

    expect(submit_paper_page).to have_paper_title
    expect(submit_paper_page).to have_paper_authors
    expect(submit_paper_page).to have_paper_declarations
    dashboard_page = submit_paper_page.submit
    expect(dashboard_page.submitted_papers).to include paper.short_title
    paper_page = dashboard_page.view_submitted_paper paper.short_title
    expect(paper_page.title).to eq paper.title
  end
end
