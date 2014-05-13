class TahiNotifier
  def self.subscribe(*listeners)
    listeners.flatten.each do |listener|
      ActiveSupport::Notifications.subscribe(to_regexp(listener)) do |name, start, finish, id, payload|
        yield(payload)
      end
    end
  end

  def self.to_regexp(name = nil)
    n = name.gsub(/\*$/, '')
    %r{^#{Regexp.escape(n)}}
  end
end
