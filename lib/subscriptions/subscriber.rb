module Subscriptions

  # Wraps ActiveSupport::Notifications to subscribe to internal application events.
  #
  class Subscriber

    # Performs the event subscription.
    #
    # Use `Subscriptions.configure` instead of using this directly.
    #
    def self.subscribe(event, subscribers)
      subscribers.flatten.each do |subscriber|
        ActiveSupport::Notifications.subscribe(/\A#{APPLICATION_EVENT_NAMESPACE}:#{event}/) do |name, _start, _finish, _id, data|
          subscriber.call(name, data)
        end
      end
    end

  end
end
