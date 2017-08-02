# Manage creating scheduled events
class ScheduledEventFactory
  attr_reader :due_datetime, :owner_id, :owner_type

  def initialize(object)
    @due_datetime = object.due_datetime
    @owner_id = object.id
    @owner_type = object.class.name
  end

  def schedule_events
    ScheduledEventTemplate.where(owner: owner_type).each do |template|
      ScheduledEvent.create name: template.event_name,
                            dispatch_at: due_datetime.due_at + template.event_dispatch_offset.days,
                            due_datetime: due_datetime,
                            owner_type: owner_type,
                            owner_id: owner_id
    end
  end
end
