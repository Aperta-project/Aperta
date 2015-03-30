class EventStream

  attr_accessor :action, :record, :subscription_name

  def initialize(action, record, subscription_name)
    @action = action
    @record = record
    @subscription_name = subscription_name
  end

  def post
    Accessibility.new(record).users.each do |user|
      #TODO look up what channel to use based on subscription_name
      #
      # lookups = {
      # "task:updated" => ->(record){ "paper_#{record.paper.id}" },
      # "paper:updated" => ->(record){ "paper_#{record.id}" }
      # }
      #
      # channel = "private-user_#{user.id}-#{lookups[subscription_name].call(record)"

      payload = payload_for(user)
      EventStreamConnection.post_event(channel_name: channel, action: subscription_name, payload: payload)
    end
  end

  def destroy
    channel = EventStreamConnection::SYSTEM_CHANNEL_NAME
    EventStreamConnection.post_event(channel, destroyed_payload)
  end

  def destroy_for(user)
    if Accessibility.new(record).disconnected?(user) && user
      channel = EventStreamConnection.channel_name(User, user.id)
      EventStreamConnection.post_event(channel, destroyed_payload)
    end
  end

  private

  def payload_for(user)
    serializer = record.event_stream_serializer(user)
    serializer.as_json.merge(action: action, subscription_name: subscription_name).to_json
  end

  def destroyed_payload
    { action: "destroyed",
      type: record.class.base_class.name.demodulize.tableize,
      ids: [record.id],
      subscription_name: subscription_name
    }.to_json
  end
end
