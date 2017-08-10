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
    active_owned_events = ScheduledEvent.owned_by(owner_type, owner_id).active.all
    return schedule_new_events if active_owned_events.blank?
    update_scheduled_events
  end

  private

  def dispatch_date(event)
    return nil unless due_datetime
    due_datetime.due_at + event[:dispatch_offset].days
  end

  def reschedule(event, template)
    new_date = dispatch_date(template)
    if event.complete? # already fired
      if event.dispatch_at < new_date
        new_event = event.dup
        new_event.dispatch_at = new_date
        new_event.save
      end
    end

    event.deactivate! if event.active? && event.dispatch_at > new_date
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
