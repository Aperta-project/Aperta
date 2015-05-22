class TahiNotifier
  def self.notify(event:, payload:)
    ActiveSupport::Notifications.instrument(event, payload)
  end

  def self.subscribe(*listeners)
    listeners.flatten.each do |listener|
      ActiveSupport::Notifications.subscribe(to_regexp(listener)) do |_name, _start, _finish, _id, payload|
        yield(payload)
      end
    end
  end

  def self.to_regexp(name = nil)
    n = name.gsub(/\*$/, '')
    %r{^#{Regexp.escape(n)}}
  end
end
