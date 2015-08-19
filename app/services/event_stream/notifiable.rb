module EventStream::Notifiable
  extend ActiveSupport::Concern
  included do
    after_commit :notify, if: -> { previous_changes.present? }

    # if false (default), do not send event stream message to original requester
    # if true, send event stream message to the original requester
    attr_accessor :notify_requester

    def notify
      Notifier.notify(event: event_name, payload: event_payload)
    end

    def event_payload
      {
        action: action,
        record: self,
        requester_socket_id: (RequestStore.store[:requester_pusher_socket_id] unless notify_requester)
      }
    end

    def payload(user: nil)
      # user can be optionally passed into serializer
      event_stream_serializer(user: user).to_json
    end

    def event_stream_serializer(user: nil)
      # user can be optionally passed into serializer
      active_model_serializer.new(self, user: user)
    end

    def destroyed_payload
      {
        type: self.class.base_class.name.demodulize.tableize,
        ids: [self.id]
      }.to_json
    end

    private

    def event_name
      "#{klass_name}:#{action}"
    end

    def klass_name
      self.class.base_class.name.underscore
    end

    def action
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
