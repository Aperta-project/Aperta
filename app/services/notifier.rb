class Notifier
  def self.notify(event:, data:)
    ActiveSupport::Notifications.instrument("tahi:#{event}", data)
  end

  def self.subscribe(event, handlers)
    handlers.flatten.each do |handler|
      ActiveSupport::Notifications.subscribe(/\Atahi:#{event}/) do |name, _start, _finish, _id, data|
        handler.call(name, data)
      end
    end
  end
end
