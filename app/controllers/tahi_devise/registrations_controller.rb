module TahiDevise
  class RegistrationsController < Devise::RegistrationsController
    def create
      invite_code = params["user"]["invite_code"]

      super do |user|
        if session["devise.provider"].present?
          key, data = session["devise.provider"].first
          user.credentials.first_or_create(uid: data.uid, provider: key)
        end

        # TODO: ensure no errors
        if invite_code.present?
          invitation = Invitation.where(code: invite_code).first

          if invitation && user
            invitation.update(invitee: user)
          end
        end
      end
    end
  end
end
