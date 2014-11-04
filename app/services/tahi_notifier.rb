class TahiNotifier
  def self.subscribe(*listeners)
    listeners.flatten.each do |listener|
      ActiveSupport::Notifications.subscribe(to_regexp(listener)) do |name, _start, _finish, _id, payload|
        yield(name, payload)
      end
    end
  end

  def self.to_regexp(name = nil)
    n = name.gsub(/\*$/, '')
    %r{^#{Regexp.escape(n)}}
  end
end
