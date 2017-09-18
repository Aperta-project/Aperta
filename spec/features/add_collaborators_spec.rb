require 'rails_helper'

feature "Adding collaborators", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt }
  let(:paper) do
    FactoryGirl.create :paper, :with_tasks, journal: journal, creator: author
  end
  let!(:user) { FactoryGirl.create :user }

  before do
    assign_journal_role(journal, author, :admin)
    login_as(author, scope: :user)
    visit "/papers/#{paper.id}"
  end

  scenario "Managing collaborators" do
    edit_paper = PaperPage.new
    collaborators_overlay = edit_paper.show_contributors
    collaborators_overlay.add_collaborators(user)
    collaborators_overlay.save

    expect(edit_paper).to have_no_application_error
    expect(page).to have_content "Upload Manuscript"

    collaborators_overlay = edit_paper.show_contributors
    expect(collaborators_overlay).to have_collaborators(user)

    collaborators_overlay = edit_paper.show_contributors
    collaborators_overlay.remove_collaborators(user)
    collaborators_overlay.save

    expect(edit_paper).to have_no_application_error
    expect(page).to have_content "Upload Manuscript"

    collaborators_overlay = edit_paper.show_contributors
    expect(collaborators_overlay).to have_no_collaborator(user)
  end
end
