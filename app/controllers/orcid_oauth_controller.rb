class OrcidOauthController < ApplicationController
  before_action :authenticate_user!

  def callback
    if params[:error] && !params[:error].blank?
      render html: <<-TEMPLATE.html_safe
        <script>
          window.localStorage.setItem('orcidOauthResult', 'failure')
        </script>
        <h1>Error</h1>
        <p>An error occured. Please close this window and try again</p>
      TEMPLATE
    else
      OrcidWorker.perform_async(current_user.id, params[:code])
      render html: <<-TEMPLATE.html_safe
        <script>
          window.localStorage.setItem('orcidOauthResult', 'success');
          window.close();
        </script>
        <h1>Success</h1>
        <p>Please close this pop-up window</p>
      TEMPLATE
    end
  end
end
