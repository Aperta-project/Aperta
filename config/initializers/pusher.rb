if TahiPusher::Config.enabled?
  Pusher.app_id = ENV.fetch("EVENT_STREAM_APP_ID")
  Pusher.key    = ENV.fetch("EVENT_STREAM_KEY")
  Pusher.secret = ENV.fetch("EVENT_STREAM_SECRET")
  Pusher.host   = ENV.fetch("EVENT_STREAM_API_HOST")
  Pusher.port   = ENV.fetch("EVENT_STREAM_API_PORT").to_i
  Pusher.logger = Rails.logger

  # SSL enabled for non-development
  unless ["development", "test"].include?(Rails.env)
    Pusher.encrypted = true
    Pusher.default_client.sync_http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end
