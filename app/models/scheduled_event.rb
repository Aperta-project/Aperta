# A scheduled event an initiative of the Automated Chasing epic.
#
# At the time of its conceptions, these events are the mechanisms through which
# chasing events are accounted for. This would also serve as contents of a queue
# on which "Eventamatron" would work off to maintain the states of chasing events
class ScheduledEvent < ActiveRecord::Base
  belongs_to :due_datetime

  include AASM

  aasm column: :state do
    state :active, initial: true
    state :inactive
    state :complete

    event(:activate) do
      transitions from: :inactive, to: :active
    end

    event(:deactivate) do
      transitions from: :active, to: :inactive
    end

    event(:trigger) do
      transitions from: :active, to: :complete
    end
  end
end
