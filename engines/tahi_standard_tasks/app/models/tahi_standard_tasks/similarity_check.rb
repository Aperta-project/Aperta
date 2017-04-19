module TahiStandardTasks
  #
  # This manages the state of a single request to iThenticate for a similarity
  # check. The SimilarityCheckTask can have multiple requests. In practice, we
  # should avoid making more than one request per paper.
  #
  class SimilarityCheck < ::ActiveRecord::Base
    include EventStream::Notifiable
    include AASM

    belongs_to :user
    belongs_to :paper
    belongs_to :task

    validates :user, presence: true
    validates :paper, presence: true
    validates :task, presence: true

    aasm column: :state do
      # It's 'pending' before the job has been started by a worker
      state :pending, initial: true

      # It's 'in_progress' once the job has been picked up by a worker
      state :in_progress

      # It's 'delivered' after the job has successfully completed
      state :processing, after_enter: :notify_delivery_succeeded

      state :failed

      state :report_complete

      event(:delivery_in_progress) do
        transitions from: :pending, to: :in_progress
      end

      event(:delivery_succeeded) do
        transitions from: :in_progress, to: :processing
      end

      event(:delivery_failed) do
        transitions from: :in_progress, to: :failed, after: :save_error
      end

      event(:report_completed) do
        transitions from: :processing, to: :report_complete, after: :update_task
      end
    end

    private

    def notify_delivery_succeeded
      notify action: 'delivery_succeeded'
    end

    def save_error(message)
      self.error_message = message
    end
  end
end
