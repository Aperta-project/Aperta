module TahiPusher
  class Channel
    # loaded into ember client via pusher-override.coffee
    def self.as_json(options={})
      {
        enabled: enabled?,
        host: ENV["EVENT_STREAM_WS_HOST"],
        port: ENV["EVENT_STREAM_WS_PORT"],
        auth_endpoint_path: auth_endpoint,
        key: Pusher.key,
        channels: default_channels
      }
    end

    def self.auth_endpoint
      Rails.application.routes.url_helpers.auth_event_stream_path
    end

    def self.default_channels
      ["system"]
    end

    def self.enabled?
      ENV["PUSHER_ENABLED"] != "false"
    end

    def authorized?(user:, channel_name:)
      channel = ChannelNameParser.new(channel_name: channel_name)
      return true if channel.public?
      return false unless Paper.exists?(channel.get(:paper))
      Accessibility.new(Paper.find(channel.get(:paper))).users.include?(user)
    end

    def authenticate(channel_name:, socket_id:)
      Pusher[channel_name].authenticate(socket_id)
    end
  end
end
