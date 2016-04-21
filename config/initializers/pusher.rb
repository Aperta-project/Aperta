if ENV.key?('PUSHER_URL')
  Pusher.url = ENV.fetch('PUSHER_URL')
else
  Pusher.app_id = ENV.fetch("EVENT_STREAM_APP_ID")
  Pusher.key = ENV.fetch("EVENT_STREAM_KEY")
  Pusher.secret = ENV.fetch("EVENT_STREAM_SECRET")
  Pusher.host = ENV.fetch("EVENT_STREAM_API_HOST")
  Pusher.port = ENV.fetch("EVENT_STREAM_API_PORT").to_i
end

if ConfigHelper.read_boolean_env('DISABLE_PUSHER_SSL_VERIFICATION')
  Pusher.default_client.sync_http_client.ssl_config.verify_mode =
    OpenSSL::SSL::VERIFY_NONE
end
Pusher.logger = Rails.logger
