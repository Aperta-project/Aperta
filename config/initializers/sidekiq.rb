sentinel_list = TahiEnv.redis_sentinels.map do |sentinel_host|
  { host: sentinel_host, port: TahiEnv.redis_port }
end

Sidekiq.configure_server do |config|
  if TahiEnv.redis_sentinel_enabled?
    config.redis = {
      master_name: 'aperta',
      sentinels: sentinel_list,
      failover_reconnect_timeout: 20,
      namespace: "tahi_#{Rails.env}"
    }
  else
    config.redis = {
      namespace: "tahi_#{Rails.env}"
    }
  end
  # allow configuration of concurrency without redeploy
  # controls the number of redis connections
  sidekiq_workers = Integer(ENV.fetch 'SIDEKIQ_CONCURRENCY', 25)
  config.options[:concurrency] = sidekiq_workers

  ActiveSupport.on_load(:active_record) do
    ar_config = ActiveRecord::Base.configurations[Rails.env]
    ar_config['pool'] = sidekiq_workers
    ActiveRecord::Base.establish_connection(ar_config)
  end

  Rails.logger.info "Sidekiq started with WORKERS=#{sidekiq_workers}"
end

Sidekiq.configure_client do |config|
  if TahiEnv.redis_sentinel_enabled?
    config.redis = {
      master_name: 'aperta',
      sentinels: sentinel_list,
      failover_reconnect_timeout: 20,
      namespace: "tahi_#{Rails.env}"
    }
  else
    config.redis = {
      namespace: "tahi_#{Rails.env}"
    }
  end
end
