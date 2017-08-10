# A scheduled event an initiative of the Automated Chasing epic.
#
# At the time of its conceptions, these events are the mechanisms through which
# chasing events are accounted for. This would also serve as contents of a queue
# on which "Eventamatron" would work off to maintain the states of chasing events
class ScheduledEvent < ActiveRecord::Base
  belongs_to :due_datetime

  include AASM

  scope :active, -> { where state: 'active' }

  def self.owned_by(type, id)
    where(owner_type: type, owner_id: id)
  end

  aasm column: :state do
    # possible states
    # processing for doing stuff
    # inactive for manual turn off
    # inactive for reschedule
    state :active, initial: true
    state :inactive
    state :complete

    event(:activate) do
      transitions from: :inactve, to: :active
    end

    event(:trigger) do
      transitions from: :active, to: :complete
    end

    event(:deactivate) do
      transitions from: :active, to: :inactive
    end
  end
end
