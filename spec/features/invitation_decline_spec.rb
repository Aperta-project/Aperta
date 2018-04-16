# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'support/invitation_feature_helpers'
require 'support/pages/dashboard_page'
require 'support/pages/overlays/invitation_overlay'

# rubocop:disable Metrics/BlockLength
feature "Invite Reviewer", js: true do
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
  let!(:letter_template) { FactoryGirl.create(:letter_template, :reviewer_declined, journal: paper.journal) }

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
