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

    event :fail_report do
      transitions to: :failed
    end
  end

  def start_report_async
    SimilarityCheckStartReportWorker.perform_async(id)
  end

  def start_report!
    raise "Manuscript file not found" unless file.url

    response = ithenticate_api.add_document(
      content: Faraday.get(file.url).body,
      filename: file[:file],
      title: paper.title,
      author_first_name: paper.creator.first_name,
      author_last_name: paper.creator.last_name,
      folder_id: folder_id
    )

    if ithenticate_api.errors?
      record_and_raise_error(ithenticate_api.errors.join(' '))
    end

    self.ithenticate_document_id = response["uploaded"].first["id"]
    self.timeout_at = Time.now.utc + TIMEOUT_INTERVAL
    self.document_s3_url = file.url
    upload_document!
  end

  def give_up_if_timed_out!
    message = "Report timed out after #{TIMEOUT_INTERVAL/60} minutes."
    record_and_raise_error(message) if Time.current.utc > timeout_at
  end

  def sync_document!
    message = 'Unable to sync document without ithenticate_id.'
    record_and_raise_error(message) if ithenticate_document_id.blank?

    document_response = ithenticate_api.get_document(
      id: ithenticate_document_id
    )
    record_and_raise_error(document_response.error) if document_response.error

    if document_response.report_complete?
      self.ithenticate_report_id = document_response.report_id
      self.ithenticate_score = document_response.score
      self.ithenticate_report_completed_at = Time.current.utc
      paper.tasks_for_type(TahiStandardTasks::SimilarityCheckTask)
        .each(&:complete!)
      finish_report!
    else
      give_up_if_timed_out!
    end
  end

  def report_view_only_url
    raise IncorrectState, "Report not yet completed" unless report_complete?
    response = ithenticate_api.get_report(id: ithenticate_report_id)
    response.view_only_url
  end

  private

  def record_and_raise_error(message)
    self.update_column(:error_message, message)
    fail_report!
    raise error_message
  end

  def ithenticate_api
    @ithenticate_api ||= Ithenticate::Api.new_from_tahi_env
  end

  def folder_id
    @folder_id ||= Sidekiq.redis do |redis|
      folder = redis.get('ithenticate_folder')
      if folder.nil?
        response = ithenticate_api.call(method: 'folder.list')
        raise 'Error getting iThenticate folder' if response['folders'].nil?
        folder = response['folders'].first['id'].to_i
        redis.set('ithenticate_folder', folder)
      end
      folder
    end
  end
end
