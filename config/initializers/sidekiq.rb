Sidekiq.configure_server do |config|
  config.redis = {
    namespace: "tahi_#{Rails.env}"
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    namespace: "tahi_#{Rails.env}"
  }
end
