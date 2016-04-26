Pusher.url = ENV.fetch('PUSHER_URL')
Pusher.logger = Rails.logger

if ConfigHelper.read_boolean_env('DISABLE_PUSHER_SSL_VERIFICATION')
  Pusher.default_client.sync_http_client.ssl_config.verify_mode =
    OpenSSL::SSL::VERIFY_NONE
end
