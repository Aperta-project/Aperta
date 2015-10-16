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
        # +subscriber_name+ is so we do not reference the subscriber directly.
        # If we do it breaks auto reloading in development environment by
        # keeping an old class reference around. Instead, store its name and
        # constantize at the we need to use it.
        subscriber_name = subscriber.name

        ActiveSupport::Notifications.subscribe(/\A#{APPLICATION_EVENT_NAMESPACE}:#{event}/) do |name, _start, _finish, _id, data|
          subscriber_name.constantize.call(name, data)
        end
      end
    end

  end
end
