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

    if response.blank? || response["api_status"] != 200
      self.update_column(:error_message, 'Error connecting to the Ithenticate server.')
      fail_report!
      raise "Error connecting to the Ithenticate server"
    end

    self.ithenticate_document_id = response["uploaded"].first["id"]
    self.timeout_at = Time.now.utc + TIMEOUT_INTERVAL
    self.document_s3_url = file.url
    upload_document!
  end

  def give_up_if_timed_out!
    self.update_column(:error_message, 'Report timed out after 10 minutes.')
    fail_report! if Time.now.utc > timeout_at
  end

  def sync_document!
    if ithenticate_document_id.blank?
      self.update_column(:error_message, 'Unable to sync document without ithenticate_id.')
      fail_report!
    end

    document_response = ithenticate_api.get_document(
      id: ithenticate_document_id
    )
    self.error_message = document_response.error
    if error_message.present?
      self.save
      timeout! #Timeout immediately if there is an error
    end

    if document_response.report_complete?
      self.ithenticate_report_id = document_response.report_id
      self.ithenticate_score = document_response.score
      self.ithenticate_report_completed_at = Time.now.utc
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
