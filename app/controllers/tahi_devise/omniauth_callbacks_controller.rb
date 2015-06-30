module TahiDevise
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def cas
      ned = NedProfile.new(cas_id: auth[:uid])
      user = get_user_with_credential(ned.cas_id, :cas)

      # update user profile with latest attributes from NED
      user.first_name = ned.first_name
      user.last_name = ned.last_name
      user.email = ned.email
      user.username = ned.display_name
      user.auto_generate_password

      if user.save
        sign_in_and_redirect(user, event: :authentication)
      else
        raise 'TODO: Figure out what to do when this errors out!'
      end
    end

    # it looks like orcid actually returns user profile information, so why are we redirecting to a page to add additional info?
    def orcid
      user = get_user_with_credential(auth[:uid], :orchid)
      if credential.present?
        sign_in_and_redirect(credential.user, event: :authentication)
      else
        session["devise.provider"] = { "orcid" => auth }
        redirect_to new_user_registration_url
      end
    end

    private

    def get_user_with_credential(uid, provider)
      if credential
        credential.user
      else
        User.new.tap do |u|
          u.credentials.build(uid: uid, provider: provider)
        end
      end
    end

    def credential
      Credential.find_by(auth.slice(:uid, :provider))
    end

    def auth
      @auth ||= request.env['omniauth.auth']
    end

  end
end
