class EventStream

  attr_reader :record, :channel_name

  def initialize(record)
    @record = record
  end

  def post(action:)
    TahiPusher::Channel.new(channel_name: channel_name).push(event_name: action, payload: record.payload)
  end

  def destroyed
    TahiPusher::Channel.new(channel_name: channel_name).push(event_name: "destroyed", payload: record.destroyed_payload)
  end


  private

  def channel_name
    @channel_name ||= TahiPusher::ChannelName.build(record.channel_model)
  end
end
