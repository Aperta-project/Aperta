#
# InvitationOverlay is a test helper for the "Reviewer Invitation" overlay
# used by the application.
#
class InvitationOverlay < Page
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
    fill_in "declineReason", with: 'reason for decline'
  end

  def enter_reviewer_suggestions
    fill_in "reviewerSuggestions", with: 'new reviewer suggestions'
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
    all('.reviewer-invitation-feedback')
  end

  def close_overlay
    find('.overlay-close').click
  end
end
