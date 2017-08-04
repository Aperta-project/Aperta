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
    template.each do |event|
      ScheduledEvent.create name: event[:name],
                            dispatch_at: dispatch_date(event),
                            due_datetime: due_datetime,
                            owner_type: owner_type,
                            owner_id: owner_id
    end
  end

  private

  def dispatch_date(event)
    return nil unless due_datetime
    due_datetime.due_at + event[:dispatch_offset].days
  end
end
