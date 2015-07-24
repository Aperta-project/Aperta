module TahiDevise
  class SessionsController < Devise::SessionsController

    def create
      associate_user_by_invitation_code(current_user)
      super
    end

  end
end
