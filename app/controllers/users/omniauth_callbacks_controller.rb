module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def orcid
      @user = User.find_by(request.env['omniauth.auth'].slice(:uid, :provider))

      if @user.try(:persisted?)
        sign_in_and_redirect(@user, :event => :authentication)
        set_flash_message(:notice, :success, :kind => "Orcid") if is_navigational_format?
      else
        #TODO: handle new user creation
        # session["devise.facebook_data"] = request.env["omniauth.auth"]
        # redirect_to new_user_registration_url
      end
    end
  end
end
