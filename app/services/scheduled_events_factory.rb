# Manage creating scheduled events
class ScheduledEventFactory
  def self.schedule_events(object)
    ScheduledEventTemplate.where(owner: object.class.name).each do |template|
      ScheduledEvent.create name: template.event_name,
                            dispatch_at: object.due_datetime.due_at + template.event_dispatch_offset,
                            due_datetime: object.due_datetime
    end
  end
end
