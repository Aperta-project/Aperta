# coding: utf-8
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

# coding: utf-8

require 'support/pages/page'
require 'support/rich_text_editor_helpers'

#
# InvitationOverlay is a test helper for the "Reviewer Invitation" overlay
# used by the application.
#
class InvitationOverlay < Page
  include RichTextEditorHelpers

  def expect_pending_invitation_count(count)
    expect(all_pending_invitations.count).to eq(count)
  end

  def expect_declined_waiting_feedback_invitation_count(count)
    expect(all_declined_waiting_feedback_invitations.count).to eq(count)
  end

  def decline_invitation(element_number)
    within all_pending_invitations[element_number - 1] do
      click_button 'Decline'
    end
  end

  def submit_feedback
    enter_decline_reason
    enter_reviewer_suggestions
    press_send_feedback
  end

  def enter_decline_reason
    set_rich_text editor: 'declineReason', text: 'reason for decline'
  end

  def enter_reviewer_suggestions
    set_rich_text editor: 'reviewerSuggestions', text: 'new reviewer suggestions'
  end

  def press_send_feedback
    click_button 'Send Feedback'
  end

  def cancel_feedback
    click_link 'No Thank You'
  end

  def expect_success_message
    expect(page).to have_css(
      '.flash-message-content',
      text: 'Thank you for your feedback! ×'
    )
  end

  def all_pending_invitations
    all('.pending-invitation')
  end

  def all_declined_waiting_feedback_invitations
    all('.invitation-feedback')
  end

  def close_overlay
    find('.overlay-close').click
  end
end
