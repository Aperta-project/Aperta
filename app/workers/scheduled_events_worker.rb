# Scheduled Events Worker (Eventamatron)
class ScheduledEventsWorker
  include Sidekiq::Worker

  def perform
    due_events = ScheduledEvent.active.where('dispatch_at < ?', DateTime.now.in_time_zone)
    return unless due_events.exists?
    due_events.each do |event|
      event.trigger!
      Activity.reminder_sent!(event)
    end
  end
end
