module EventStream
  class Broadcaster
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def post(action:, channel_scope:, excluded_socket_id: nil)
      return unless TahiPusher::Config.enabled?

      if action == "destroyed"
        payload = record.destroyed_payload
        channel_name = TahiPusher::ChannelName.build(
          target: TahiPusher::Config::SYSTEM_CHANNEL,
          access: TahiPusher::ChannelName::PUBLIC
        )
      else
        payload = channel_scope.is_a?(User) ? record.payload(user: channel_scope) : record.payload
        channel_name = TahiPusher::ChannelName.build(
          target: channel_scope,
          access: TahiPusher::ChannelName::PRIVATE
        )
      end
      TahiPusher::Channel.new(channel_name: channel_name).push(event_name: action, payload: payload, excluded_socket_id: excluded_socket_id)
    end
  end
end
