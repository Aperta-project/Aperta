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

# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'notifier'

module EventStream::Notifiable
  extend ActiveSupport::Concern
  included do
    class_attribute :notifications_enabled
    self.notifications_enabled = true

    after_commit :notify, if: :changes_committed?

    # if false (default), do not send event stream message to original requester
    # if true, send event stream message to the original requester
    attr_accessor :notify_requester

    def notify(action: nil, payload: nil)
      return unless notifications_enabled?

      payload ||= event_payload(action: action)

      klasses = self.class.ancestors.select do |ancestor|
        ancestor <= self.class.base_class
      end

      klasses.each do |klass|
        name = event_name(action: action, klass: klass)
        Notifier.notify(event: name, data: payload)
      end
    end

    def event_payload(action: nil)
      action ||= event_action
      {
        action: action,
        record: self,
        requester_socket_id: (RequestStore.store[:requester_pusher_socket_id] unless notify_requester),
        current_user_id: RequestStore.store[:requester_current_user_id]
      }
    end

    private

    def event_name(action: nil, klass:)
      action ||= event_action
      "#{klass.name.underscore}:#{action}"
    end

    def changes_committed?
      destroyed? || previous_changes.present?
    end

    def event_action
      if previous_changes[:created_at].present?
        "created"
      elsif self.destroyed?
        "destroyed"
      else
        "updated"
      end
    end
  end
end
