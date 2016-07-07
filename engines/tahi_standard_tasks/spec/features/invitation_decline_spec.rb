require 'rails_helper'

feature "Invite Reviewer", js: true do
  let(:editor) { create :user }
  let(:task) { FactoryGirl.create :paper_reviewer_task }
  let!(:invitation_no_feedback) do
    FactoryGirl.create(:invitation, :invited, task: task, invitee: editor)
  end
  let!(:invitation) do
    FactoryGirl.create(:invitation, :invited, task: task, invitee: editor)
  end

  let(:dashboard) { DashboardPage.new }
  let(:invitation_overlay) { InvitationOverlay.new }

  before do
    login_as(editor, scope: :user)
    visit "/"
    dashboard.press_view_invitations_button
  end

  scenario 'decline invitations' do
    invitation_overlay.expect_pending_invitation_count(2)

    # decline and send feedback
    invitation_overlay.decline_invitation(1)
    invitation_overlay.submit_feedback
    invitation_overlay.expect_success_message
    invitation_overlay.expect_pending_invitation_count(1)

    # decline and cancel feedback
    invitation_overlay.decline_invitation(1)
    invitation_overlay.cancel_feedback
    dashboard.expect_active_invitations_count(0)

    invitation.reload
    expect(invitation.decline_reason).to eq('reason for decline')
    expect(invitation.reviewer_suggestions).to eq('new reviewer suggestions')

    invitation2.reload
    expect(invitation2.decline_reason).to eq(nil)
    expect(invitation2.reviewer_suggestions).to eq(nil)
  end
end
