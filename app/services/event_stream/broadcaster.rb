module EventStream
  class Broadcaster
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def post(action:, channel_scope:)
      if action == "destroyed"
        payload = record.destroyed_payload
        channel_name = TahiPusher::ChannelName.build(
          target: TahiPusher::Config::SYSTEM_CHANNEL,
          access: TahiPusher::ChannelName::PUBLIC
        )
      else
        payload = record.payload
        channel_name = TahiPusher::ChannelName.build(
          target: channel_scope,
          access: TahiPusher::ChannelName::PRIVATE
        )
      end
      TahiPusher::Channel.new(channel_name: channel_name).push(event_name: action, payload: payload)
    end
  end
end
