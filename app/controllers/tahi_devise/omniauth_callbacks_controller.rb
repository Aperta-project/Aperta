module TahiDevise
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def cas
      ned = auth[:extra]
      downcased_email = ned[:emailAddress].strip.downcase
      user =
        if credential.present?
          credential.user
        else
          User.find_or_create_by(email: downcased_email).tap do |user|
            user.credentials.build(uid: auth[:uid], provider: :cas)
          end
        end
      # update user profile with latest attributes from NED
      user.first_name = ned[:firstName]
      user.last_name = ned[:lastName]
      user.email = downcased_email
      user.username = ned[:displayName]
      user.ned_id = ned[:nedId]
      user.auto_generate_password
      user.save!

      sign_in_and_redirect(user, event: :authentication)
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
