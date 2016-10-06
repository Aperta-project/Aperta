class OrcidWorker
  include Sidekiq::Worker
  require 'active_support'

  sidekiq_options retry: 5

  def perform(user_id, authorization_code)
    response = oauth_authorize(authorization_code)
    response_hash = JSON.parse(response.body)

    orcid_account = OrcidAccount.find_or_create_by(user_id: user_id)
    orcid_account.access_token = response_hash['access_token']
    orcid_account.refresh_token = response_hash['refresh_token']
    orcid_account.identifier = response_hash['orcid']
    orcid_account.expires_at = DateTime.now.utc + response_hash['expires_in'].seconds
    orcid_account.name = response_hash['name']
    orcid_account.scope = response_hash['scope']
    orcid_account.authorization_code_response = response_hash
    orcid_account.save!

    OrcidProfileWorker.perform_in(5.seconds, orcid_account.id)
  end

  private

  def oauth_authorize(code)
    # client id and secret are Aperta's id and secret, NOT the end user's
    RestClient.post(
      "https://#{ENV['ORCID_SITE_HOST']}/oauth/token", {
        'client_id' => ENV['ORCID_KEY'],
        'client_secret' => ENV['ORCID_SECRET'],
        'grant_type' => 'authorization_code',
        'code' => code
      }, 'Accept' => 'application/json'
    )
  rescue RestClient::ExceptionWithResponse => ex
    raise OrcidAccount::APIError, ex.to_s
  end
end
