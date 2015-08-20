class EventStreamSubscriber

  attr_reader :action, :record, :excluded_socket_id

  def self.call(event_name, event_data)
    subscriber = new(event_name, event_data)
    subscriber.run
  end

  def initialize(event_name, event_data)
    @action = event_data[:action]
    @record = event_data[:record]
    @excluded_socket_id = event_data[:requester_socket_id]
  end

  def run
    EventStream::Broadcaster.post(action: action, payload: payload, channel_scope: channel, excluded_socket_id: excluded_socket_id)
  end

  def payload
    raise NotImplementedError.new("You must define the data that is sent to pusher")
  end

  def channel
    raise NotImplementedError.new("You must define the ActiveRecord model that determines the pusher channel")
  end

end
