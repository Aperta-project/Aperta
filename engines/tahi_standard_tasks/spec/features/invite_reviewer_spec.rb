require 'rails_helper'

feature "Invite Reviewer", js: true do
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }
  let!(:reviewer1) { create :user }
  let!(:reviewer2) { create :user }
  let!(:reviewer3) { create :user }

  before do
    assign_journal_role journal, editor, :editor
    paper.paper_roles.create user: editor, old_role: PaperRole::COLLABORATOR
    task.add_participant(editor)

    login_as(editor, scope: :user)
    visit "/"
  end

  scenario "Editor can invite any user as a reviewer to a paper" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.paper_reviewers = [reviewer1]
    expect(overlay).to have_reviewers reviewer1.full_name
  end

  scenario "displays invitations from the latest round of revisions" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.paper_reviewers = [reviewer1]
    expect(overlay.active_invitations_count(1)).to be true

    paper.decisions.create!

    overlay.reload
    overlay = Page.view_task_overlay(paper, task)
    overlay.paper_reviewers = [reviewer3, reviewer2]
    expect(overlay.expired_invitations_count(1)).to be true
    expect(overlay.active_invitations_count(2)).to be true
    expect(overlay.total_invitations_count(3)).to be true
  end
end
