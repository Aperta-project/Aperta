class OrcidProfileWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(orcid_id)
    OrcidAccount.find(orcid_id).update_orcid_profile!
  end
end
