module EventStreamNotifier
  extend ActiveSupport::Concern
  included do
    after_commit :notify

    def notify
      # don't notify for empty updates
      if action == "updated" && previous_changes.empty?
        logger.info "COMMIT no-up update for for #{self.class.name}:#{self.id}"
      else
        ActiveSupport::Notifications.instrument(namespace, event_stream_payload)
      end
    end

    def event_stream_payload
      notifier_payload.merge({ action: action, records_to_load: records_to_load})
    end

    def notifier_payload
      { id: id, paper_id: paper.id, type: klass_name }
    end

    def records_to_load
      [{type: klass_name, id: id}]
    end

    private

    def namespace
      "#{klass_name}:#{action}"
    end

    def klass_name
      self.class.base_class.name.underscore.gsub('/', '_')
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
