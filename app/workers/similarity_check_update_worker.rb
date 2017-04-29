# This worker runs periodically. See sidekiq.yml
# It checks all the of the SimilarityChecks which are waiting on ithenticate.
class SimilarityCheckUpdateWorker
  include Sidekiq::Worker

  # TODO: make this work.
  def perform
    SimilarityCheck.waiting_for_report.each do |similarity_check|
      document_response = ithenticate_api.get_document(id: similarity_check.ithenticate_document_id)

      binding.pry
      if document_response.report_complete?
        similarity_check.report_id = document_response.report_id
        report_response = ithenticate_api.get_report(id: report_id)

        if report_response.success?
          similarity_check.report_url = report_response.report_url
          similarity_check.score = report_response.score
          return similarity_check.finish_report!
        end
      end

      similarity_check.give_up_if_timed_out!
    end
  end

  def ithenticate_api
    @ithenticate_api ||= Ithenticate::Api.new_from_tahi_env
  end
end
