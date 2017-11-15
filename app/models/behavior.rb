# Defines a "behavior" which triggers some code on a certain event.

class Behavior < ActiveRecord::Base
  include Attributable

  belongs_to :journal

  validates :event_name, presence: true, inclusion: { in: ->(_) { Event.allowed_events } }

  self.inheritance_column = 'action'

  def self.sti_name
    name.gsub(/Behavior$/, '').underscore
  end

  def self.find_sti_class(type_name)
    "#{type_name.camelize}Behavior".constantize
  end

  # Main entry point for a behavior.
  def call(_event)
    raise NotImplementedError
  end
end
