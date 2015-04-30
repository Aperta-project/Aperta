class EventStream

  attr_reader :record

  def initialize(record)
    @record = record
  end

  def post(action:)
    TahiPusher::Channel.new(channel_name: channel_name).push(event_name: action, payload: payload_for(action))
  end


  private

  def payload_for(action)
    if action == "destroyed"
      record.destroyed_payload
    else
      record.payload
    end
  end

  def channel_name
    @channel_name ||= TahiPusher::ChannelName.build(record.channel_model)
  end
end
