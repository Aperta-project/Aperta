require 'rails_helper'

feature "Invite Reviewer", js: true do
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) do
    FactoryGirl.create(
      :paper, :submitted_lite, :with_creator, journal: journal)
  end
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }
  let!(:reviewer1) { create :user, first_name: 'Henry' }
  let!(:reviewer2) { create :user, first_name: 'Henroff' }
  let!(:reviewer3) { create :user, first_name: 'Henrietta' }

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

    # Already invited users don't show up again the search
    overlay.fill_in 'Reviewer', with: 'Hen'
    expect(page).to have_no_css('.auto-suggest-item', text: reviewer1.full_name)

    # But, users who have not been invited should still be suggested
    expect(page).to have_css('.auto-suggest-item', text: reviewer2.full_name)
    expect(page).to have_css('.auto-suggest-item', text: reviewer3.full_name)
  end

  scenario "displays invitations from the latest round of revisions" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.paper_reviewers = [reviewer1]
    expect(overlay.active_invitations_count(1)).to be true

    register_paper_decision(paper, 'minor_revision')
    paper.submit! paper.creator

    overlay.reload
    overlay = Page.view_task_overlay(paper, task)
    overlay.paper_reviewers = [reviewer3, reviewer2]
    expect(overlay.expired_invitations_count(1)).to be true
    expect(overlay.active_invitations_count(2)).to be true
    expect(overlay.total_invitations_count(3)).to be true
  end
end
