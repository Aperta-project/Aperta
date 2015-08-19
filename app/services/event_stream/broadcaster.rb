module EventStream
  class Broadcaster
    def self.post(action:, payload:, channel_scope:, excluded_socket_id: nil)
      return unless TahiPusher::Config.enabled?

      if action == "destroyed"
        channel_name = TahiPusher::ChannelName.build(
          target: TahiPusher::Config::SYSTEM_CHANNEL,
          access: TahiPusher::ChannelName::PUBLIC
        )
      else
        channel_name = TahiPusher::ChannelName.build(
          target: channel_scope,
          access: TahiPusher::ChannelName::PRIVATE
        )
      end
      TahiPusher::Channel.delay(queue: :eventstream, retry: false).push(channel_name: channel_name, event_name: action, payload: payload, excluded_socket_id: excluded_socket_id)
    end
  end
end
