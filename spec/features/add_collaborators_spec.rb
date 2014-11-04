require 'spec_helper'

feature "Editing paper", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, submitted: false, short_title: 'foo bar', user: author }
  let!(:user) { FactoryGirl.create :user }
  let(:collaborating_user) { FactoryGirl.create :user }
  let!(:paper_role) { PaperRole.create user: collaborating_user, paper: paper, role: 'collaborator' }

  before do
    make_user_paper_admin(author, paper)

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Adding New Collaborators" do
    edit_paper = EditPaperPage.visit paper
    collaborators_overlay = edit_paper.show_contributors
    collaborators_overlay.add_collaborators(user)
    collaborators_overlay.save
    expect(edit_paper).to have_no_application_error
    sleep 0.2 #we can't figure out why clicking the link too quickly doesn't work.
    collaborators_overlay = EditPaperPage.new.show_contributors
    expect(collaborators_overlay).to have_collaborators(user)
  end

  scenario "Removing an existing collaborator", selenium: true do
    edit_paper = EditPaperPage.visit paper
    collaborators_overlay = edit_paper.show_contributors
    expect(collaborators_overlay).to have_collaborators(collaborating_user)
    collaborators_overlay.remove_collaborators(collaborating_user, author)
    collaborators_overlay.save
    expect(edit_paper).to have_no_application_error
    sleep 0.2 #we can't figure out why clicking the link too quickly doesn't work.
    collaborators_overlay = EditPaperPage.new.show_contributors
    expect(collaborators_overlay).to have_no_collaborators
  end

end
