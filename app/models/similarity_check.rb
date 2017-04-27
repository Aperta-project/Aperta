#
# This manages the state of a single request to iThenticate for a similarity
# check. The SimilarityCheckTask can have multiple requests. In practice, we
# should avoid making more than one request per paper.
#
class SimilarityCheck < ::ActiveRecord::Base
  include EventStream::Notifiable
  include AASM

  belongs_to :versioned_text

  validates :versioned_text, :state, presence: true

  aasm column: :state do
    # It's 'pending' before the job has been started by a worker
    state :needs_upload, initial: true
    state :waiting_for_report
    state :failed
    state :report_complete

    event :upload_document do
      transitions from: :needs_upload, to: :waiting_for_report
    end
  end

  def start_report
    SimilarityCheckStartReportWorker.perform_async(id)
  end
end
