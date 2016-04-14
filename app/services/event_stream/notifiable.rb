# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'notifier'

module EventStream::Notifiable
  extend ActiveSupport::Concern
  included do
    after_commit :notify, if: :changes_committed?

    # if false (default), do not send event stream message to original requester
    # if true, send event stream message to the original requester
    attr_accessor :notify_requester

    def notify(action: nil, payload: nil)
      name = event_name(action: action)
      payload ||= event_payload(action: action)
      Notifier.notify(event: name, data: payload)
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

    def event_name(action: nil)
      action ||= event_action
      "#{klass_name}:#{action}"
    end

    def klass_name
      self.class.base_class.name.underscore
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
