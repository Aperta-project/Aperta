require 'spec_helper'

feature "Editing paper", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author edits paper" do
    edit_paper = EditPaperPage.visit paper
    # edit_paper.short_title = "lorem-ipsum"
    edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
    edit_paper.abstract = "Lorem Ipsum is simply dummy text"
    edit_paper.body = "Contrary to popular belief"

    binding.pry
    dashboard_page = edit_paper.save
    binding.pry
    edit_paper.navigate_to_dashboard
    # expect(dashboard_page.submissions).to include "Lorem Ipsum Dolor Sit Amet"

    edit_paper = EditPaperPage.visit paper
    binding.pry
    expect(edit_paper.title).to eq "Lorem Ipsum Dolor Sit Amet"
    # expect(edit_paper.abstract).to match /Lorem Ipsum is simply dummy text/
    expect(edit_paper.body).to eq "Contrary to popular belief"
  end
end
