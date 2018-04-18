module TahiDevise
  class SessionsController < Devise::SessionsController
    include DisableSubmissions

    def create
      super { flash[:alert] = sign_in_alert }
    end
  end
end
