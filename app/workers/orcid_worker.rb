class OrcidWorker
  include Sidekiq::Worker
  require 'active_support'

  sidekiq_options retry: 5

  def perform(user_id, authorization_code)
    orcid_account = OrcidAccount.find_by(user_id: user_id)
    orcid_account.exchange_code_for_token(authorization_code)

    OrcidProfileWorker.perform_in(5.seconds, orcid_account.id)
  end
end
