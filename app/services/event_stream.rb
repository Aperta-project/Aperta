class EventStream

  attr_accessor :action, :record, :subscription_name

  def initialize(action, record, subscription_name)
    @action = action
    @record = record
    @subscription_name = subscription_name
  end

  def post
    Accessibility.new(record).users.each do |user|
      channel = EventStreamConnection.channel_name(User, user.id)
      payload = payload_for(user)
      EventStreamConnection.post_event(channel, payload)
    end
  end

  def destroy
    channel = EventStreamConnection::SYSTEM_CHANNEL_NAME
    payload = {
      action: "destroyed",
      type: record.class.base_class.name.demodulize.tableize,
      ids: [record.id],
      subscription_name: subscription_name
    }.to_json
    EventStreamConnection.post_event(channel, payload)
  end

  def destroy_for(user)
    if Accessibility.new(record).disconnected?(user)
      channel = EventStreamConnection.channel_name(User, user.id)
      payload = {
        action: "destroyed",
        type: record.class.base_class.name.demodulize.tableize,
        ids: [record.id],
        subscription_name: subscription_name
      }.to_json
      EventStreamConnection.post_event(channel, payload)
    end
  end

  private

  def payload_for(user)
    serializer = record.event_stream_serializer(user)
    serializer.as_json.merge(action: action, subscription_name: subscription_name).to_json
  end
end
