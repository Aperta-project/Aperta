if TahiEnv.redis_sentinel_enabled?
  Sidekiq.redis = {
    url: ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL'],
    role: :master,
    # This option is actually the master name, not a host
    host: 'aperta',
    sentinels: TahiEnv.redis_sentinels.map do |s|
      u = URI.parse(s)
      { host: u.host, port: (u.port || 26_379) }
    end,
    failover_reconnect_timeout: 20,
    namespace: "tahi_#{Rails.env}"
  }
else
  Sidekiq.redis = { namespace: "tahi_#{Rails.env}" }
end

Sidekiq.configure_server do |config|
  ActiveSupport.on_load(:active_record) do
    ar_config = ActiveRecord::Base.configurations[Rails.env]
    ar_config['pool'] = config.options[:concurrency]
    ActiveRecord::Base.establish_connection(ar_config)
  end
end
