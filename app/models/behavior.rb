# Defines a "behavior" which triggers some code on a certain event.

class Behavior < ActiveRecord::Base
  include Attributable

  belongs_to :journal

  validates :event_name, presence: true, inclusion: { in: ->(_) { Event.allowed_events_including_descendants } }

  # Main entry point for a behavior.
  def call(_event)
    raise NotImplementedError
  end
end
