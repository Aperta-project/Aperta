require 'rails_helper'

feature "Editing paper", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) do
    FactoryGirl.create :paper, :with_tasks, journal: journal, creator: author
  end
  let!(:user) { FactoryGirl.create :user }

  before do
    make_user_paper_admin(author, paper)
    login_as(author, scope: :user)
    visit "/"
  end

  scenario "Managing collaborators" do
    click_link paper.title
    edit_paper = PaperPage.new
    collaborators_overlay = edit_paper.show_contributors
    collaborators_overlay.add_collaborators(user)
    collaborators_overlay.save

    expect(edit_paper).to have_no_application_error
    expect(page).to have_content "Upload Manuscript"

    collaborators_overlay = edit_paper.show_contributors

    expect(collaborators_overlay).to have_collaborators(user)

    collaborators_overlay.remove_collaborators(user, author)
    collaborators_overlay.save

    expect(edit_paper).to have_no_application_error
    expect(page).to have_content "Upload Manuscript"

    collaborators_overlay = edit_paper.show_contributors

    expect(collaborators_overlay).to have_no_collaborators
  end
end
