module TahiPusher
  class Config
    SYSTEM_CHANNEL = "system"

    # injected into ember layout (ember.html.erb)
    # then loaded into ember client (pusher-override.coffee)
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
      [SYSTEM_CHANNEL]
    end

    def self.enabled?
      # assume enabled even if environment variable is not set
      ENV["PUSHER_ENABLED"] != "false"
    end

    def self.verbose_logging?
      # detailed rails server logs will be recorded for pusher communication
      ENV["PUSHER_VERBOSE_LOGGING"] == "true"
    end
  end
end
