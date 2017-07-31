# Manage creating scheduled events
class ScheduledEventFactory
  def self.schedule_events(object)
    # handle already existing events (either delete or mark as inactive)
    # scenario: * moving the due_datetime,
    #           * rescheduling events,
    #           * changing state where the events become unnecesarry

    ScheduledEventTemplate.where(owner: object.class.name).each do |template|
      # check to make sure that the effective date generated from dispatch is not in the past
      # try to use the deactivated or inactive states.
      ScheduledEvent.create name: template.event_name,
                            dispatch_at: object.due_datetime.due_at + template.event_dispatch_offset.days,
                            due_datetime: object.due_datetime
    end
  end
end
