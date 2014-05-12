module EventStreamNotifier
  extend ActiveSupport::Concern
  included do
    after_commit :notify

    def notify
      ActiveSupport::Notifications.instrument(namespace, event_stream_payload)
    end

    def event_stream_payload
      task_payload.merge!(action: action)
    end

    def task_payload
      { task_id: id, journal_id: journal.id }
    end

    private

    def namespace
      "#{klass_name}:#{action}"
    end

    def klass_name
      self.class.base_class.name.downcase
    end

    def action
      if previous_changes[:created_at].present?
        "created"
      elsif previous_changes[:updated_at].present?
        "updated"
      else
        "destroyed"
      end
    end
  end
end
