module InvitationCodes
  extend ActiveSupport::Concern

  included do
    before_action :set_invitation_code
  end

  private

  # called every request
  def set_invitation_code
    invitation_code = params["invitation_code"]

    if invitation_code.present?
      if Invitation.where(code: invitation_code).invited.exists?
        session["invitation_code"] = invitation_code
      else
        flash[:alert] = "The invitation is no longer active or has expired."
      end
    end

    if session["invitation_code"] && current_user
      associate_user_with_invitation(current_user)
    end
  end

  # called after login or signup
  def associate_user_with_invitation(user)
    if invitation_code = session["invitation_code"]
      invitation = Invitation.where(code: invitation_code).invited.first
      invitation.update(invitee: user) if invitation
      clear_invitation_code
    end
  end

  def clear_invitation_code
    session["invitation_code"] = nil
  end
end
