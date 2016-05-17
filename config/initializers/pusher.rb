Pusher.url = ENV.fetch('PUSHER_URL')
Pusher.logger = Rails.logger

if TahiEnv.enable_pusher_ssl_verification?
  Pusher.default_client.sync_http_client.ssl_config.verify_mode =
    OpenSSL::SSL::VERIFY_NONE
end
