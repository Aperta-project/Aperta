class PusherSubscriber

  attr_reader :action, :record, :excluded_socket_id

  def self.call(event_name, event_data)
    subscriber = new(event_name, event_data)
    subscriber.run
  end

  def initialize(event_name, event_data)
    @action = event_data[:action]
    @record = event_data[:record]
    @excluded_socket_id = event_data[:excluded_socket_id]
  end

  def run
    broadcaster = EventStream::Broadcaster.new(resource)
    broadcaster.post(action: action, channel_scope: channel, excluded_socket_id: excluded_socket_id)
  end

  def resource
    raise NotImplementedError.new("You must define the ActiveRecord record to pass to the Broadcaster!")
  end

  def channel
    raise NotImplementedError.new("You must define the Pusher Channel to send the data!")
  end

end
