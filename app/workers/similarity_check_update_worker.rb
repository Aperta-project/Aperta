# This worker runs periodically. See sidekiq.yml
# It checks all the of the SimilarityChecks which are waiting on ithenticate.
class SimilarityCheckUpdateWorker
  include Sidekiq::Worker

  # TODO: make this work.
  def perform
    SimilarityCheck.waiting_for_report.each do |similarity_check|
      response = ithenticate_api.check_document(similarity_check.document_id)

      if response.success?
        similarity_check.report_url = response.report_url
        similarity_check.report_id = repsonse.report_id
        similarity_check.finish_report!
      elsif similarity_check.timed_out?
        similarity_check.give_up!
      end
    end
  end

  def ithenticate_api
    @ithenticate_api ||= IthenticateApi.new_from_tahi_env
  end
end
