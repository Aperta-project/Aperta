require 'rails_helper'

feature "Invite Academic Editor", js: true do
  include SidekiqHelperMethods

  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) do
    FactoryGirl.create(
      :paper, :submitted_lite, :with_creator, journal: journal
    )
  end
  let(:task) { FactoryGirl.create :paper_editor_task, paper: paper }

  let(:staff_admin) { create :user }
  let!(:editor1) { create :user, first_name: 'Henry' }
  let!(:editor2) { create :user, first_name: 'Henroff' }
  let!(:editor3) { create :user, first_name: 'Henrietta' }

  before do
    assign_journal_role journal, staff_admin, :admin
    login_as(staff_admin, scope: :user)
    visit "/"
  end

  scenario "links alternate candidates with other potential editors" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.invited_users = [editor1]
    expect(overlay).to have_invitees editor1.full_name

    overlay.fill_in 'invitation-recipient', with: editor2.email
    overlay.find('.invitation-email-entry-button').click

    # Using the capybara-select2 helper here doesn't work because... not sure.
    # I think we are using select2 strangely here.
    overlay.edit_invitation(editor2)
    within(".invitation-item--edit") do
      find('.link-alternate-select.select2-container').click
    end

    find(".select2-highlighted").click
    find(".invitation-save-button").click
    expect(page.find('.alternate-link-icon')).to be_present
  end

  scenario 'Any user can be invited as an Academic Editor on a paper' do
    overlay = Page.view_task_overlay(paper, task)
    overlay.invited_users = [editor1]
    expect(overlay).to have_invitees editor1.full_name

    # Already invited users don't show up again the search
    overlay.fill_in 'invitation-recipient', with: 'Henr'
    expect(page).to have_no_css('.auto-suggest-item', text: editor1.full_name)

    # But, users who have not been invited should still be suggested
    expect(page).to have_css('.auto-suggest-item', text: editor2.full_name)
    expect(page).to have_css('.auto-suggest-item', text: editor3.full_name)
    overlay.dismiss

    overlay.sign_out

    login_as(editor1)
    visit '/'

    dashboard = DashboardPage.new
    dashboard.view_invitations do |invitations|
      expect(invitations.count).to eq 1
      invitations.first.accept("Accept Academic Editor Invitation")
      expect(dashboard).to have_no_pending_invitations
    end
    dashboard.reload

    within('.active-paper-table-row') do
      expect(page).to have_content('Academic Editor')
    end
  end

  scenario 'attaching files to invitations' do
    overlay = Page.view_task_overlay(paper, task)
    overlay.add_to_queue(editor1)
    ActiveInvitation.for_user(editor1) do |invite|
      invite.edit(editor1)
      invite.upload_attachment('yeti.jpg')
    end
    find('.invitation-save-button').click

    # Make sure we get the attachment in the actual email
    overlay.find('.invitation-item-action-send').click
    process_sidekiq_jobs
    email = find_email(editor1.email)
    expect(email).to be
    # expect(email.attachments.map(&:filename)).to contain_exactly 'yeti.jpg'
  end
end
