module TahiDevise
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def orcid
      oauthorize(:orcid)
    end

    def cas
      oauthorize(:cas)
    end

    private

    def oauthorize(provider_name)
      credential = Credential.find_by(auth.slice(:uid, :provider))
      if credential
        sign_in_and_redirect(credential.user, event: :authentication)
      else
        session["devise.provider"] = { provider_name.to_s => auth }
        redirect_to new_user_registration_url
      end
    end

    def auth
      @auth ||= request.env['omniauth.auth']
    end

    def profile
      auth['info']['orcid_bio']
    end
  end
end
