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

  after_create :start_report

  aasm column: :state do
    # It's 'pending' before the job has been started by a worker
    state :pending, initial: true

    # It's 'in_progress' once the job has been picked up by a worker
    state :in_progress
    state :failed
    state :report_complete
  end

  def start_report
    SimilarityCheckStartReportWorker.perform_async(id)
  end
end
