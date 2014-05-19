module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def orcid
      user = User.find_by(auth.slice(:uid, :provider))
      if user.try(:persisted?)
        sign_in_and_redirect(user, event: :authentication)
      else
        session["devise.orcid"] = auth
        redirect_to new_user_registration_url
      end
    end

    private

    def auth
      @auth ||= request.env['omniauth.auth']
    end

    def profile
      auth['info']['orcid_bio']
    end
  end
end
