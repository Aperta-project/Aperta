# This class provides the glue between internal application events and any
# subscribers listening to that event.
#
# It also provides a single source of truth for all event subscriptions, no
# matter where the event is registered (Tahi Core or your favorite external
# gem/engine).
#
# Subscriptions should be registered upon app initialization, commonly
# `config/initializers/subscriptions.rb`
#
# Use `rake subscriptions` to see a full list of events and their subscribers.
#
module Subscriptions
  DuplicateSubscribersRegistrationError = Class.new(StandardError)
  APPLICATION_EVENT_NAMESPACE = Rails.application.railtie_name

  class << self

    # Provides a simple DSL for configuring internal subscriptions.
    # There is only 1 action: `add`.
    #
    # ```ruby
    # Subscriptions.configure do
    #   add 'my:sweet_event', SweetEventSubscriber, Other::Interested::Subscriber
    #   add 'event_name', List, Of, Subscriber, Classes
    # end
    # ```
    #
    # Each event may be added multiple times, but each Subscriber class may only
    # be active for a given event once. This prevents accidentally registering a
    # subscriber twice for the same event. This is easy to do when events are
    # registered across several different codebases (Tahi Core and several gems).
    #
    def configure(&block)
      configure_blocks << block
      __registry__.instance_eval(&block)
      self
    end

    # Returns all subscriber classes for a given event in the registry.
    def subscribers_for(event)
      __registry__.subscribers_for(event)
    end

    # prints out the current list of subscriptions in a style similar to the
    # output of `rake routes`
    def pretty_print(io=$stdout)
      __registry__.pretty_print(io)
    end

    def reload
      unsubscribe_all
      configure_blocks.each do |block|
        __registry__.instance_eval(&block)
      end
    end

    def reset
      unsubscribe_all
    end

    # Remove all subscriptions from the registry.  Useful when testing.
    def unsubscribe_all
      @registry.unsubscribe_all
    end

    private

    def configure_blocks
      @configure_blocks ||= []
    end

    # One registry to rule them all.
    def __registry__
      @registry ||= Subscriptions::Registry.new
    end
  end

end
