module EventStreamNotifier
  extend ActiveSupport::Concern
  included do
    after_commit :notify

    def notify
      ActiveSupport::Notifications.instrument(namespace, event_stream_payload)
    end

    def event_stream_payload
      p = notifier_payload.merge({ action: action, klass: self.class.base_class, id: self.id })
      if has_meta?
        p = p.merge({meta: { model_name: meta_type, id: meta_id }})
      end
      p
    end

    def event_stream_serializer
      active_model_serializer
    end

    #TODO: can this be removed as part of the EventStream changes?
    def notifier_payload
      {}
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
