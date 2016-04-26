module InvitationCodes
  extend ActiveSupport::Concern

  included do
    before_action :set_invitation_code_from_params
    before_action :associate_current_user_with_invitation_code_from_session
  end

  private

  def set_invitation_code_from_params
    invitation_code = params["invitation_code"]
    return if invitation_code.blank?

    if Invitation.where(code: invitation_code).invited.exists?
      unless current_user
        flash[:notice] = "To accept or decline your invitation, please sign in or create an account."
      end
      session["invitation_code"] = invitation_code
    else
      flash[:alert] = "We're sorry, the invitation is no longer active."
    end
  end

  # User#associate_invites will have caught most of the invite use cases. This is
  # for the times where a user has their account associated with one email but has been
  # invited by another.
  def associate_current_user_with_invitation_code_from_session
    invitation_code = session["invitation_code"]
    return unless invitation_code.present? && current_user

    invitation = Invitation.where(code: invitation_code).invited.first
    invitation.update(invitee: current_user) if invitation
    clear_invitation_code
  end

  def clear_invitation_code
    session["invitation_code"] = nil
  end
end
