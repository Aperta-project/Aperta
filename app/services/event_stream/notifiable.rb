module EventStream::Notifiable
  extend ActiveSupport::Concern
  included do
    after_commit :notify

    def notify
      TahiNotifier.notify(event: namespace, payload: event_stream_payload)
    end

    def event_stream_payload
      { action: action, record: self }
    end

    def event_stream_serializer(user)
      active_model_serializer.new(self, user: user)
    end

    private

    def namespace
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
