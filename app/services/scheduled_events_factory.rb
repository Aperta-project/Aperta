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
    return schedule_new_events unless owned_active_events.present?
    update_scheduled_events
  end

  private

  def owned_active_events
    ScheduledEvent.owned_by(owner_type, owner_id).active
  end

  def dispatch_date(event)
    return nil unless due_datetime
    (due_datetime.due_at + event[:dispatch_offset].days).beginning_of_hour
  end

  def reschedule(event, template)
    new_date = dispatch_date(template)

    if event.complete?
      if event.dispatch_at < new_date
        new_event = event.dup
        event.reactivate
        event.dispatch_at = new_date
        new_event.save
      end
    end

    event.dispatch_at = new_date
    event.save
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
      event = ScheduledEvent.owned_by(owner_type, owner_id).where(name: entry[:name]).first
      reschedule event, entry
    end
  end
end
