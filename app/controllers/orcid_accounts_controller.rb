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
