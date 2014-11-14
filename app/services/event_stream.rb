class EventStream

  attr_accessor :action, :record, :subscription_name

  def initialize(action, record, subscription_name)
    @action = action
    @record = record
    @subscription_name = subscription_name
  end

  def post
    Accessibility.new(record).users.each do |user|
      EventStreamConnection.post_user_event(
        user.id,
        payload_for(user)
      )
    end
  end

  def destroy
    EventStreamConnection.post_system_event(
      { action: "destroyed",
        type: record.class.base_class.name.demodulize.tableize,
        ids: [record.id],
        subscription_name: subscription_name }.to_json
    )
  end

  private

  def payload_for(user)
    serializer = record.event_stream_serializer(user)
    serializer.as_json.merge(action: action, subscription_name: subscription_name).to_json
  end
end
