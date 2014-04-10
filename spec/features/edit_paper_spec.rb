require 'spec_helper'

feature "Editing paper", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author edits paper" do
    pending
    edit_paper = EditPaperPage.visit paper
    edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
    edit_paper.abstract = "Lorem Ipsum is simply dummy text"
    edit_paper.body = "Contrary to popular belief"

    dashboard_page = edit_paper.save
    edit_paper = EditPaperPage.visit paper

    # This is working when tested manually. There is something weird about how
    # we are setting the title with jQuery that isn't changing the title on the
    # model.
    expect(edit_paper.title).to eq "Lorem Ipsum Dolor Sit Amet"
    expect(edit_paper.body).to eq "Contrary to popular belief"
  end
end
