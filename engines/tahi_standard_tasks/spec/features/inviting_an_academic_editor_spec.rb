require 'rails_helper'

feature 'Invite Academic Editor', js: true do
  let(:admin) { FactoryGirl.create(:user) }
  let!(:editor1) { FactoryGirl.create(:user, first_name: 'Steve') }
  let!(:editor2) { FactoryGirl.create(:user, first_name: 'Stephen') }
  let!(:editor3) { FactoryGirl.create(:user, first_name: 'Stephanie') }
  let(:creator) { FactoryGirl.create(:user) }
  let(:paper) do
    FactoryGirl.create(
      :paper, :submitted_lite,
      :with_integration_journal, creator: creator)
  end
  let!(:task) do
    FactoryGirl.create(:paper_editor_task, paper: paper)
  end

  before do
    assign_journal_role(paper.journal, admin, :admin)

    login_as(admin, scope: :user)
    visit "/papers/#{paper.id}/tasks/#{task.id}"
  end

  scenario 'Any user can be invited as an Academic Editor on a paper' do
    overlay = InviteEditorOverlay.new
    expect(overlay).to be_uncompleted
    overlay.create_invite_for(editor1, send_now: true)

    overlay.mark_as_complete
    expect(overlay).to have_invite_for editor1

    # Already invited users don't show up again the search
    overlay.fill_in 'invitation-recipient', with: 'Ste'
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
    overlay = InviteEditorOverlay.new
    overlay.create_invite_for(editor1, send_now: false)
    ActiveInvitation.for_user(editor1) do |invite|
      invite.show_details
      invite.upload_attachment('yeti.jpg')
    end
  end
end
