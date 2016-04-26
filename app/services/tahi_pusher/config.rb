module TahiPusher
  class Config
    SYSTEM_CHANNEL = "system"

    # injected into ember layout (ember.html.erb)
    # then loaded into ember client (pusher-override.coffee)
    def self.as_json(_ = {})
      {
        enabled: true,
        auth_endpoint_path:
          Rails.application.routes.url_helpers.auth_event_stream_path,
        key: Pusher.key,
        channels: [SYSTEM_CHANNEL]
      }.merge(socket_options)
    end

    def self.socket_options
      if defined?(PusherFake)
        PusherFake.configuration.socket_options
      elsif ENV.key?('PUSHER_SOCKET_URL')
        # I believe this works because pusher has a standard host & port to use
        # and does not require setting.
        {}
      else
        {
          host: ENV["EVENT_STREAM_WS_HOST"],
          port: ENV["EVENT_STREAM_WS_PORT"]
        }
      end
    end
  end
end
