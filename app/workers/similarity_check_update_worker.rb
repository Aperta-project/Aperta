# This worker runs periodically. See sidekiq.yml
# It checks all the of the SimilarityChecks which are waiting on ithenticate.
class SimilarityCheckUpdateWorker
  include Sidekiq::Worker
  # This uniqueness constraint means that there can't be more than one of this
  # job type running at a time. Also it means that there can't be more than one
  # of this job type queued at time. If we attempt to queue a job which would
  # violate that constraint, the job is dropped and a warning appears in the
  # sidekiq log.
  # https://github.com/mhenrixon/sidekiq-unique-jobs
  sidekiq_options unique: :until_and_while_executing,
                  log_duplicate_payload: true

  def perform
    SimilarityCheck.waiting_for_report.each(&:sync_document!)
  end
end
