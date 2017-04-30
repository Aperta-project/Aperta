# This worker runs periodically. See sidekiq.yml
# It checks all the of the SimilarityChecks which are waiting on ithenticate.
class SimilarityCheckUpdateWorker
  include Sidekiq::Worker

  # TODO: make this work.
  def perform
    SimilarityCheck.waiting_for_report.each(&:sync_document!)
  end

  def ithenticate_api
    @ithenticate_api ||= Ithenticate::Api.new_from_tahi_env
  end
end
