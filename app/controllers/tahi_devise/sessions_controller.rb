module TahiDevise
  class SessionsController < Devise::SessionsController
    def create
      super { flash[:alert] = sign_in_alert }
    end

    private

    def sign_in_alert
      return unless FeatureFlag['DISABLE_SUBMISSIONS']
      <<-HTML
        <div class='disable-submissions-alert'>
          <p>Please note that we are transitioning to another submission system and are no longer accepting new submissions in Aperta</p>
          <ul>
            <li>To submit your manuscript for consideration at <em>PLOS Biology</em>, please visit Editorial Management</li>
            <li>You may continue to edit or revise existing existing <em>PLOS Biology</em> submissions that are already under consideration</li>
          </ul>
          <p>Contact us with any concerns at: plosbiology@plos.org. Learn more about submitting to PLOS Biology</p>
        </div>
      HTML
    end
  end
end
