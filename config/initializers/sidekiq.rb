redis_config = if TahiEnv.redis_sentinel_enabled?
                 {
                   master_name: 'aperta',
                   sentinels: TahiEnv.redis_sentinels,
                   failover_reconnect_timeout: 20,
                   namespace: "tahi_#{Rails.env}"
                 }
               else
                 {
                   namespace: "tahi_#{Rails.env}"
                 }
               end
Sidekiq.configure_server do |config|
  config.redis = redis_config
  # allow configuration of concurrency without redeploy
  # controls the number of redis connections
  sidekiq_workers = 25
  config.options[:concurrency] = sidekiq_workers

  ActiveSupport.on_load(:active_record) do
    ar_config = ActiveRecord::Base.configurations[Rails.env]
    ar_config['pool'] = sidekiq_workers
    ActiveRecord::Base.establish_connection(ar_config)
  end

  Rails.logger.info "Sidekiq started with WORKERS=#{sidekiq_workers}"
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
