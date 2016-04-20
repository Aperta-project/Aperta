module TahiDevise
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def cas
      ned = auth[:extra]
      ned[:emailAddress] = ned[:emailAddress].strip.downcase
      user =
        if credential.present?
          credential.user
        else
          User.find_or_create_by(email: ned[:emailAddress]).tap do |user|
            user.credentials.build(uid: auth[:uid], provider: :cas)
          end
        end

      # update user profile with latest attributes from NED
      user.first_name = ned[:firstName]
      user.last_name = ned[:lastName]
      user.email = ned[:emailAddress]
      user.username = ned[:displayName]
      user.auto_generate_password
      user.save!

      sign_in_and_redirect(user, event: :authentication)
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
      if credential.present?
        sign_in_and_redirect(credential.user, event: :authentication)
      else
        session["devise.provider"] = { "orcid" => auth }
        redirect_to new_user_registration_url
      end
    end

    private

    def credential
      @credential ||= Credential.find_by(auth.slice(:uid, :provider))
    end

    def auth
      @auth ||= request.env['omniauth.auth']
    end

  end
end
