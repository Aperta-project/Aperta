module TahiDevise
  class RegistrationsController < Devise::RegistrationsController
    def create
      super do |user|
        if session["devise.provider"].present?
          associate_user_by_invitation_code(user)

          key, data = session["devise.provider"].first
          user.credentials.first_or_create(uid: data.uid, provider: key)
        end
      end
    end
  end
end
