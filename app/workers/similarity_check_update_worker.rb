# This worker runs periodically. See sidekiq.yml
# It checks all the of the SimilarityChecks which are waiting on ithenticate.
class SimilarityCheckUpdateWorker
  include Sidekiq::Worker

  def perform
    SimilarityCheck.waiting_for_report.each(&:sync_document!)
  end
end
