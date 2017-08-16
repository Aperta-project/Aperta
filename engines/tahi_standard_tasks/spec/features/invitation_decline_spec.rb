require 'rails_helper'

feature "Invite Reviewer", js: true, flaky: true do
  include InvitationFeatureHelpers

  let(:inviter) { create :user }
  let(:editor) { create :user }
  let(:paper) { FactoryGirl.create :paper, :submitted_lite }
  let(:task) { FactoryGirl.create :paper_reviewer_task, :with_loaded_card, paper: paper }
  let!(:invitation_no_feedback) do
    FactoryGirl.create(
      :invitation,
      :invited,
      task: task,
      invitee: editor,
      inviter: inviter
    )
  end
  let!(:invitation) do
    FactoryGirl.create(
      :invitation,
      :invited,
      task: task,
      invitee: editor,
      inviter: inviter
    )
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
    ensure_email_got_sent_to(inviter.email)

    # decline and cancel feedback
    invitation_overlay.decline_invitation(1)
    invitation_overlay.cancel_feedback
    dashboard.expect_active_invitations_count(0)
    ensure_email_got_sent_to(inviter.email)

    invitation.reload
    expect(invitation.decline_reason).to eq('<p>reason for decline</p>')
    expect(invitation.reviewer_suggestions).to eq('<p>new reviewer suggestions</p>')

    invitation_no_feedback.reload
    # Invitation decline_reason and reviewer_suggestions are stored
    # as '' in dB, but getter in model returns 'n/a' when blank
    expect(invitation_no_feedback.decline_reason).to eq('No feedback provided')
    expect(invitation_no_feedback.reviewer_suggestions).to eq('None')
  end
end
