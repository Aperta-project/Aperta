# Broadcast events into an internal application message bus. Subscribers listen
# for these specific events. More detail about how this works can be found in
# the `Subscriptions` class.
#
# Wraps ActiveSupport::Notifications to broadcast internal application events.
#
class Notifier

  def self.notify(event:, data:)
    event_name = "#{Subscriptions::APPLICATION_EVENT_NAMESPACE}:#{event}"
    ActiveSupport::Notifications.instrument(event_name, data)
  end

end
