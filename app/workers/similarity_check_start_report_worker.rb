# This sidekiq worker uploads a document to ithenticate which triggers the
# generation of a similarity report. A different worker will then poll the
# Ithenticate API to check if the report is finished.
class SimilarityCheckStartReportWorker
  include Sidekiq::Worker

  def perform(similarity_check_id)
    # download file
    # base64 encode file
    # call api
    # save results of call on similarity check model
  end

  def ithenticate_api
    @ithenticate_api ||= IthenticateApi.new
  end
end
