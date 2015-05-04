module EventStream
  class Broadcaster
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def post(action:, channel_scope:)
      payload = payload_for(action)
      channel_name = TahiPusher::ChannelName.build(channel_scope)
      TahiPusher::Channel.new(channel_name: channel_name).push(event_name: action, payload: payload)
    end


    private

    def payload_for(action)
      if action == "destroyed"
        record.destroyed_payload
      else
        record.payload
      end
    end
  end
end
