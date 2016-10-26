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
    login_as(editor, scope: :user)
    visit "/"
  end

  scenario "Editor can invite any user as a reviewer to a paper" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.invited_users = [reviewer1]
    expect(overlay).to have_invitees reviewer1.full_name

    # Already invited users don't show up again the search
    overlay.fill_in 'invitation-recipient', with: 'Hen'
    expect(page).to have_no_css('.auto-suggest-item', text: reviewer1.full_name)

    # But, users who have not been invited should still be suggested
    expect(page).to have_css('.auto-suggest-item', text: reviewer2.full_name)
    expect(page).to have_css('.auto-suggest-item', text: reviewer3.full_name)
  end

  scenario "displays invitations from the latest round of revisions" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.invited_users = [reviewer1]
    expect(overlay.active_invitations_count(1)).to be true

    register_paper_decision(paper, 'minor_revision')
    paper.submit! paper.creator

    overlay.reload
    overlay = Page.view_task_overlay(paper, task)
    overlay.invited_users = [reviewer3, reviewer2]
    expect(overlay.expired_invitations_count(1)).to be true
    expect(overlay.active_invitations_count(2)).to be true
    expect(overlay.total_invitations_count(3)).to be true
  end

  scenario "links alternate candidates with other potential reviewers" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.invited_users = [reviewer1]
    expect(overlay).to have_invitees reviewer1.full_name

    overlay.fill_in 'invitation-recipient', with: reviewer2.email
    overlay.find('.invitation-email-entry-button').click

    overlay.select_first_alternate
    find('.invitation-save-button').click
    expect(page.find('.alternate-link-icon')).to be_present
  end

  scenario "prevents invitations while a review is invited in the subqueue" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.invited_users = [reviewer1]
    overlay.add_to_queue(reviewer2)
    overlay.find('.invitation-item-action-edit').click
    overlay.select_first_alternate
    overlay.find('.invitation-save-button').click

    header = find('.invitation-item-header', text: reviewer2.first_name)
    expect(header).to have_css('.invitation-item-action-send.invitation-item-action--disabled')
  end

  scenario "does not disable other invitations in the main queue when another invitation is invited/accepted" do
    overlay = Page.view_task_overlay(paper, task)
    # invited user
    overlay.invited_users = [reviewer1]
    # pending user
    overlay.add_to_queue(reviewer2)
    overlay.find('.invitation-item-action-edit').click
    overlay.find('.invitation-save-button').click

    header = find('.invitation-item-header', text: reviewer2.first_name)
    expect(header).to have_no_css('.invitation-item-action-send.invitation-item-action--disabled')
  end

  scenario "edits an invitation" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.add_to_queue(reviewer1)

    # Life is not lost by dying; life is lost minute by minute,
    # day by dragging day, in all the thousand small uncaring ways.
    overlay.find('.invitation-item-header').click
    overlay.find('.invitation-item-header').click

    overlay.find('.invitation-item-action-edit').click
    overlay.invitation_body = 'New body'
    overlay.find('.invitation-save-button').click
    expect(overlay.find('.invitation-show-body')).to have_text('New body')
  end

  scenario "deletes only a pending invitation" do
    overlay = Page.view_task_overlay(paper, task)

    # invited
    overlay.invited_users = [reviewer1]
    find('.invitation-item-header', text: reviewer1.first_name).click
    expect(overlay).to have_no_css('.invitation-item-action-delete')

    # pending
    overlay.add_to_queue(reviewer2)
    header = find('.invitation-item-header', text: reviewer2.first_name)
    expect(header).to have_css('.invitation-item-action-delete')
    header.find('.invitation-item-action-delete').click
    expect(overlay).to have_no_css('.invitation-item-header', text: reviewer2.first_name)
  end

  scenario 'attaching files to invitations' do
    overlay = Page.view_task_overlay(paper, task)
    overlay.add_to_queue(reviewer1)
    ActiveInvitation.for_user(reviewer1) do |invite|
      invite.edit
      invite.upload_attachment('yeti.jpg')
    end
  end
end
