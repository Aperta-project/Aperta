# This sidekiq worker uploads a document to ithenticate which triggers the
# generation of a similarity report. A different worker will then poll the
# Ithenticate API to check if the report is finished.
class SimilarityCheckStartReportWorker
  include Sidekiq::Worker

  def perform(similarity_check_id)
    similarity_check = SimilarityCheck.find(similarity_check_id)
    file = similarity_check.versioned_text.paper.file
    doc = Faraday.get(file.url).body

    response = ithenticate_api.add_document(
      content: doc,
      filename: file[:file],
      title: similarity_check.versioned_text.paper.title,
      author_first_name: "ninja", # TODO: fix author name
      author_last_name: "turtle",
      folder_id: 1, # TODO: fix folder id
    )

    if response["api_status"] == 200
      similarity_check.update!(
        ithenticate_document_id: response["uploaded"].first["id"]
      )
    else
      raise "ithenticate error"
    end
  end

  def ithenticate_api
    @ithenticate_api ||= IthenticateApi.new_from_tahi_env
  end
end
