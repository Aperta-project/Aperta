#
# This manages the state of a single request to iThenticate for a similarity
# check. The SimilarityCheckTask can have multiple requests. In practice, we
# should avoid making more than one request per paper.
#
class SimilarityCheck < ActiveRecord::Base
  class IncorrectState < StandardError; end

  include EventStream::Notifiable
  include AASM

  belongs_to :versioned_text
  has_one :paper, through: :versioned_text
  has_one :file, through: :paper

  validates :versioned_text, :state, presence: true

  TIMEOUT_INTERVAL = 10.minutes

  aasm column: :state do
    # It's 'pending' before the job has been started by a worker
    state :needs_upload, initial: true
    state :waiting_for_report
    state :failed
    state :report_complete

    event :upload_document do
      transitions from: :needs_upload, to: :waiting_for_report
    end

    event :finish_report do
      transitions from: :waiting_for_report, to: :report_complete
    end

    event :timeout do
      transitions from: :waiting_for_report, to: :failed
    end
  end

  def start_report_async
    SimilarityCheckStartReportWorker.perform_async(id)
  end

  def start_report!
    response = ithenticate_api.add_document(
      content: Faraday.get(file.url).body,
      filename: file[:file],
      title: paper.title,
      author_first_name: "ninja", # TODO: fix author name
      author_last_name: "turtle",
      folder_id: 921_380, # TODO: fix folder id
    )

    unless response["api_status"] == 200
      raise "ithenticate error" # TODO: expose response
    end

    self.ithenticate_document_id = response["uploaded"].first["id"]
    self.timeout_at = Time.now.utc + TIMEOUT_INTERVAL
    upload_document!
  end

  def give_up_if_timed_out!
    timeout! if Time.now.utc > timeout_at
  end

  def sync_document!
    raise "Need ithenticate_document_id" unless ithenticate_document_id
    document_response = ithenticate_api.get_document(
      id: ithenticate_document_id
    )

    if document_response.report_complete?
      self.report_id = document_response.report_id
      self.score = document_response.score
      self.ithenticate_report_completed_at = Time.now.utc
      finish_report!
    else
      give_up_if_timed_out!
    end
  end

  def report_view_only_url
    raise IncorrectState, "Report not yet completed" unless report_complete?
    response = ithenticate_api.get_report(id: report_id)
    response.view_only_url
  end

  private

  def ithenticate_api
    @ithenticate_api ||= Ithenticate::Api.new_from_tahi_env
  end
end
