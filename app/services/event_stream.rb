class EventStream

  attr_accessor :action, :klass, :id, :subscription_name

  def initialize(action, klass, id, subscription_name)
    @action = action
    @klass = klass
    @id = id
    @subscription_name = subscription_name
  end

  def post
    Accessibility.new(resource).users.each do |user|
      EventStreamConnection.post_user_event(
        user.id,
        payload_for(user)
      )
    end
  end

  def destroy
    EventStreamConnection.post_system_event(
      { action: "destroyed", type: klass.name.demodulize.tableize, ids: [id], subscription_name: subscription_name }.to_json
    )
  end

  private

  def resource
    @resource ||= klass.find(id)
  end

  def payload_for(user)
    serializer = resource.event_stream_serializer(user)
    serializer.as_json.merge(action: action, subscription_name: subscription_name).to_json
  end
end
