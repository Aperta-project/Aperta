# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

module Subscriptions

  # Wraps ActiveSupport::Notifications to subscribe to internal application events.
  #
  class Subscriber

    # Performs the event subscription.
    #
    # Use `Subscriptions.configure` instead of using this directly.
    #
    def self.subscribe(event, subscribers)
      subscribers.flatten.map do |subscriber|
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

    def self.unsubscribe(subscribers)
      subscribers.each do |subscriber|
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end
  end
end
