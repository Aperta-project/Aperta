class Notifier
  def self.notify(event:, payload:)
    ActiveSupport::Notifications.instrument(event, payload)
  end

  def self.subscribe(event_name, handlers)
    handlers.flatten.each do |handler|
      ActiveSupport::Notifications.subscribe(event_name) do |name, _start, _finish, _id, payload|
        handler.call(name, payload)
      end
    end
  end
end
