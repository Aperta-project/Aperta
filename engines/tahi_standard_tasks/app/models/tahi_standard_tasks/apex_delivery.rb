module TahiStandardTasks
  #
  # The very last thing Aperta does with an accepted manuscript is packacge up
  # the manuscript and its metadata and send it to Apex, an external vendor that
  # typesets the paper. An ApexDelivery represents the progress of gathering,
  # zipping, and sending the appropriate data to Apex.
  #
  # Works hand-in-hand with SendToApexTask.
  #
  class ApexDelivery < ::ActiveRecord::Base
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
      state :delivered, after_enter: :notify_delivery_succeeded

      state :failed

      event(:delivery_in_progress) do
        transitions from: :pending, to: :in_progress
      end

      event(:delivery_succeeded) do
        transitions from: :in_progress, to: :delivered
      end

      event(:delivery_failed) do
        transitions from: :in_progress, to: :failed
      end
    end

    private

    def notify_delivery_succeeded
      notify action: 'delivery_succeeded'
    end
  end
end
