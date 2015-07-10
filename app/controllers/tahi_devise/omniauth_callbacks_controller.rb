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
      user.save!

      sign_in_and_redirect(user, event: :authentication)

    rescue NedProfileConnectionError => ex
      redirect_to new_user_session_path, alert: "We were unable to authenticate with CAS at this time."
    end

    # We are using the "Orcid Member API", which gives us access to privilaged information.
    # It let's us query for detailed profile information. Unfortunately, Orcid's default is
    # that email addresses are private. The user can change their email address to be public,
    # and we can get it back, but let's face it, nobody's going to do that. Even though we
    # are reading "limited access data", the field is private and this prevents Orcid
    # from sending us the email address.
    #
    # So, redirect to a page that prefills any orcid profile information and collects email.
    #
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
        User.new do |u|
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
