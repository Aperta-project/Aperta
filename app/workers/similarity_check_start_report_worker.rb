# This sidekiq worker uploads a document to ithenticate which triggers the
# generation of a similarity report. A different worker will then poll the
# Ithenticate API to check if the report is finished.
class SimilarityCheckStartReportWorker
  include Sidekiq::Worker

  def perform(similarity_check_id)
    SimilarityCheck.find(similarity_check_id).start_report!
  end
end
