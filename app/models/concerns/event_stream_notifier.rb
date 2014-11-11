module EventStreamNotifier
  extend ActiveSupport::Concern
  included do
    after_commit :notify

    def notify
      ActiveSupport::Notifications.instrument(namespace, event_stream_payload)
    end

    def event_stream_payload
      p = { action: action, klass: self.class.base_class, id: self.id }
      #TODO: can we remove this?
      if has_meta?
        p = p.merge({meta: { model_name: meta_type, id: meta_id }})
      end
      p
    end

    def event_stream_serializer(user)
      active_model_serializer.new(self, user: user)
    end

    def has_meta?
      false
    end

    def meta_type
      nil
    end

    def meta_id
      nil
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
