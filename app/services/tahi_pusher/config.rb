module TahiPusher
  class Config
    SYSTEM_CHANNEL = "system"

    # injected into ember layout (ember.html.erb)
    # then loaded into ember client (pusher-override.coffee)
    def self.as_json(options={})
      {
        auth_endpoint_path: auth_endpoint,
        enabled: true,
        key: Pusher.key,
        channels: default_channels
      }.merge(socket_options)
    end

    def self.auth_endpoint
      Rails.application.routes.url_helpers.auth_event_stream_path
    end

    def self.default_channels
      [SYSTEM_CHANNEL]
    end



    def self.socket_options
      if Rails.env.test?
        PusherFake.configuration.socket_options
      elsif ENV.key?('PUSHER_SOCKET_URL')
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
