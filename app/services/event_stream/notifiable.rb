module EventStream::Notifiable
  extend ActiveSupport::Concern
  included do
    after_commit :notify

    def notify
      TahiNotifier.notify(event: event_name, payload: event_payload)
    end

    def event_payload
      { action: action, record: self, requester_socket_id: RequestStore.store[:requester_pusher_socket_id] }
    end

    def event_stream_serializer
      # active_model_serializer.new(self)
      # TODO: uncomment above once users have been removed from serializer
      active_model_serializer.new(self, user: User.last)
    end

    def payload
      event_stream_serializer.to_json
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
