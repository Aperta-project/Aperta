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
                            dispatch_at: due_datetime.due_at + event[:dispatch_offset].days,
                            due_datetime: due_datetime,
                            owner_type: owner_type,
                            owner_id: owner_id
    end
  end
end
