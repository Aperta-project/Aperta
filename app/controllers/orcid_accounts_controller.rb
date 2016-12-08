class OrcidAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :disabled_response, unless: -> { TahiEnv.orcid_connect_enabled? }
  respond_to :json

  def show
    render json: orcid_account
  end

  def clear
    requires_user_can(:remove_orcid, Journal)
    orcid_account.reset!
    render json: orcid_account
  end

  private

  def orcid_account
    @orcid_account ||= OrcidAccount.find(params[:id])
  end

  def oauth_authorize_url
    "https://#{TahiEnv.orcid_site_host}/oauth/authorize"\
    + "?client_id=#{TahiEnv.orcid_key}"\
    + "&response_type=code"\
    + "&scope=/read-limited"\
    + "&redirect_uri=#{redirect_uri}"
  end

  def redirect_uri
    port = if [80, 443].include?(request.port)
             ''
           else
             ':' + request.port.to_s
           end
    request.protocol + request.host + port + '/api/orcid/oauth'
  end

  def disabled_response
    render(
      status: 404,
      json: {
        message: 'Orcid integration is not currently enabled.'
      },
      serializer: ErrorSerializer
    )
  end
end
