module TahiStandardTasks
  #
  # The very last thing Aperta does with an accepted manuscript is packacge up
  # the manuscript and its metadata and send it to either Apex, an external vendor that
  # typesets the paper, or the article admin server (a.k.a. router). An ExportDelivery
  # represents the progress of gathering, zipping, and sending the appropriate data to
  # Apex or the router service (the latter endpoint defined by the ROUTER_URL env var).
  #
  # Works hand-in-hand with SendToApexTask and the new card config Preprint/EM export.
  #
  # TODO: move this out of the engines dir
  #
  class ExportDelivery < ::ActiveRecord::Base
    include EventStream::Notifiable
    include AASM

    belongs_to :user
    belongs_to :paper
    belongs_to :task

    validates :user, presence: true
    validates :paper, presence: true
    validates :task, presence: true
    validates :destination, presence: true, inclusion: {
      in: %w(apex em preprint)
    }

    def user_can_view?(check_user)
      check_user.can?(:send_to_apex, paper)
    end

    validate :paper_acceptance_state

    aasm column: :state do
      # It's 'pending' before the job has been started by a worker
      state :pending, initial: true

      # It's 'in_progress' once the job has been picked up by a worker
      state :in_progress

      # It's 'delivered' after the job has successfully completed
      state :delivered, after_enter: :notify_delivery_succeeded

      state :failed

      # It's 'posted' on prod (tracked for preprints only)
      state :preprint_posted

      event(:delivery_in_progress) do
        transitions from: :pending, to: :in_progress
      end

      event(:delivery_succeeded) do
        transitions from: :in_progress, to: :delivered
      end

      event(:delivery_failed) do
        transitions from: :in_progress, to: :failed, after: :save_error
      end

      event(:posted) do
        transitions from: :delivered, to: :preprint_posted
      end
    end

    private

    def notify_delivery_succeeded
      notify action: 'delivery_succeeded'
    end

    def save_error(message)
      self.error_message = message
    end

    def paper_acceptance_state
      return unless destination == 'apex' && paper.present? && !paper.accepted?
      errors.add(:paper, "must be accepted in order to send to APEX")
    end
  end
end
