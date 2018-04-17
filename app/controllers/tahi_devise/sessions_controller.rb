module TahiDevise
  class SessionsController < Devise::SessionsController
    def create
      super { flash[:alert] = sign_in_alert }
    end

    private

    def sign_in_alert
      return unless FeatureFlag['DISABLE_SUBMISSIONS']
      render_to_string(partial: 'shared/disabled_submissions_alert').squish
    end
  end
end
