# Manage creating scheduled events
class ScheduledEventFactory
  attr_reader :due_datetime, :owner_id, :owner_type, :template

  def initialize(object, template)
    @due_datetime = object.due_datetime
    @owner_id = object.id
    @owner_type = object.class.name
    @template = template
  end

  def schedule_events
    return schedule_new_events if owned_active_events.blank?
    update_scheduled_events
  end

  private

  def owned_active_events
    ScheduledEvent.owned_by(owner_type, owner_id).active.all
  end

  def dispatch_date(event)
    return nil unless due_datetime
    due_datetime.due_at + event[:dispatch_offset].days
  end

  def reschedule(event, template)
    new_date = dispatch_date(template)

    # A complete event
    if event.complete?
      # ...which moves into the future
      if event.dispatch_at < new_date
        # should continue to display in the list of Reminders (2.4)
        new_event = event.dup # are reactivated (2.2)
        event.dispatch_at = new_date
        new_event.save
      end
    end
    # Events which have not yet fired, but move into the past as part of the due date change
    if event.active? && event.dispatch_at > new_date
      # are deactivated so they will never fire. (2.3)
      event.deactivate!
    else
      # if all conditions fall through, update the event date.
      event.dispatch_at = new_date
      event.save
    end
  end

  def schedule_new_events
    template.each do |event|
      ScheduledEvent.create name: event[:name],
                            dispatch_at: dispatch_date(event),
                            due_datetime: due_datetime,
                            owner_type: owner_type,
                            owner_id: owner_id
    end
  end

  def update_scheduled_events
    template.each do |entry|
      event = ScheduledEvent.owned_by(owner_type, owner_id).where(name: entry[:name])
      reschedule event, entry
    end
  end
end
