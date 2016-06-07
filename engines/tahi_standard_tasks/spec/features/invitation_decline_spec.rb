require 'rails_helper'

feature "Invite Reviewer", js: true do
  let(:editor) { create :user }
  let(:task) { FactoryGirl.create :paper_reviewer_task }
  let!(:invitation) do
    FactoryGirl.create(:invitation, :invited, task: task, invitee: editor)
  end
  let!(:invitation2) do
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
    invitation_overlay.expect_invitation_count(2)

    # decline and send  feedback
    invitation_overlay.decline_invitation(1)
    invitation_overlay.submit_feedback
    invitation_overlay.expect_success_message
    invitation_overlay.expect_invitation_count(1)

    # deceline and cancel feedback
    invitation_overlay.decline_invitation(1)
    invitation_overlay.cancel_feedback
    dashboard.expect_active_invitations_count(0)
  end
end
