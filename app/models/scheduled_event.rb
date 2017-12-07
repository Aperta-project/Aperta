# A scheduled event an initiative of the Automated Chasing epic.
#
# At the time of its conceptions, these events are the mechanisms through which
# chasing events are accounted for. This would also serve as contents of a queue
# on which "Eventamatron" would work off to maintain the states of chasing events
class ScheduledEvent < ActiveRecord::Base
  belongs_to :due_datetime

  include AASM

  scope :active, -> { where(state: 'active') }
  scope :inactive, -> { where(state: 'inactive') }
  scope :completed, -> { where(state: 'completed') }
  scope :passive, -> { where(state: 'passive') }
  scope :due_to_trigger, -> { active.where('dispatch_at < ?', DateTime.now.in_time_zone) }
  scope :serviceable, -> { where(state: ['passive', 'active', 'completed', 'inactive']) }
  scope :cancelable, -> { where(state: ['passive', 'active']) }

  before_save :disable, if: :should_disable?
  before_save :reactivate, if: :should_reactivate?

  FINISHED_STATES = %w[completed inactive canceled errored deactivated].freeze

  def should_disable?
    dispatch_at && dispatch_at < DateTime.now.in_time_zone && (active? || passive?)
  end

  def should_reactivate?
    dispatch_at && dispatch_at > DateTime.now.in_time_zone && inactive?
  end

  def finished?
    FINISHED_STATES.include?(state)
  end

  aasm column: :state do
    state :active, initial: true
    state :inactive
    state :completed
    state :processing
    state :errored
    state :passive
    state :canceled # Canceled automatically after a qualifying event, e.g., a review is submitted
    state :deactivated

    event(:reactivate) do
      transitions from: [:completed, :inactive], to: :active
    end

    event(:disable) do
      transitions from: [:active, :passive], to: :inactive
    end

    event(:switch_off) do
      transitions from: :active, to: :passive
    end

    event(:switch_on) do
      transitions from: :passive, to: :active
    end

    event(:trigger, after_commit: [:send_email]) do
      transitions from: :active, to: :processing
    end

    event(:complete) do
      transitions from: :processing, to: :completed
    end

    event(:error) do
      transitions from: :processing, to: :errored
    end

    event(:cancel) do
      transitions from: :active, to: :canceled
      transitions from: :passive, to: :deactivated
    end
  end

  def send_email
    task_mailer = TahiStandardTasks::ReviewerMailer
    begin
      case name
      when 'Pre-due Reminder'
        task_mailer.remind_before_due(reviewer_report_id: due_datetime.due_id).deliver_now
      when 'First Late Reminder'
        task_mailer.first_late_notice(reviewer_report_id: due_datetime.due_id).deliver_now
      when 'Second Late Reminder'
        task_mailer.second_late_notice(reviewer_report_id: due_datetime.due_id).deliver_now
      end
      complete!
    rescue
      error!
    end
  end
end
