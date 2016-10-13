class OrcidWorker
  include Sidekiq::Worker
  require 'active_support'

  sidekiq_options retry: 5

  def perform(user_id, authorization_code)
    response = oauth_authorize(authorization_code)

    orcid_account = OrcidAccount.find_by(user_id: user_id)
    orcid_account.access_token = response['access_token']
    orcid_account.refresh_token = response['refresh_token']
    orcid_account.identifier = response['orcid']
    orcid_account.expires_at = DateTime.now.utc + response['expires_in'].seconds
    orcid_account.name = response['name']
    orcid_account.scope = response['scope']
    orcid_account.authorization_code_response = response
    orcid_account.save!

    OrcidProfileWorker.perform_in(5.seconds, orcid_account.id)
  end

  private

  def oauth_authorize(code)
    # client id and secret are Aperta's id and secret, NOT the end user's
    response = JSON.parse RestClient.post(
      "https://#{TahiEnv.orcid_site_host}/oauth/token", {
        'client_id' => TahiEnv.orcid_key,
        'client_secret' => TahiEnv.orcid_secret,
        'grant_type' => 'authorization_code',
        'code' => code
      }, 'Accept' => 'application/json'
    )
    if response["errorDesc"] &&
        !response['errorDesc']['content'].empty?
      raise OrcidAccount::APIError, response['errorDesc']['content']
    end
    response
  rescue RestClient::ExceptionWithResponse => ex
    raise OrcidAccount::APIError, ex.to_s
  end
end
