Pusher.url = ENV.fetch('PUSHER_URL')
Pusher.logger = Rails.logger

if TahiEnv.pusher_ssl_verify?
  Pusher.default_client.sync_http_client.ssl_config.verify_mode =
    OpenSSL::SSL::VERIFY_NONE
end
