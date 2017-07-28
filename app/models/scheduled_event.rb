# A scheduled event an initiative of the Automated Chasing epic.
#
# At the time of its conceptions, these events are the mechanisms through which
# chasing events are accounted for. This would also serve as contents of a queue
# on which "Eventamatron" would work off to maintain the states of chasing events
class ScheduledEvent < ActiveRecord::Base
  # include AASM

  belongs_to :due_datetime

  # aasm column: :state do
  #   # APERTA-9687 can begin from here
  # end
end
