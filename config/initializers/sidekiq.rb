Sidekiq.configure_server do |config|
  config.redis = {
    master_name: 'aperta',
    sentinels: [
      "sentinel://10.5.3.120:26379",
      "sentinel://10.5.3.121:26379",
      "sentinel://10.5.3.122:26379",
      "sentinel://10.5.3.123:26379"
    ],
    failover_reconnect_timeout: 20,
    namespace: "tahi_#{Rails.env}"
  }

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
  config.redis = {
    # namespace: "tahi_#{Rails.env}"
    master_name: 'aperta',
    sentinels: [
      "sentinel://10.5.3.120:26379",
      "sentinel://10.5.3.121:26379",
      "sentinel://10.5.3.122:26379",
      "sentinel://10.5.3.123:26379"
    ],
    failover_reconnect_timeout: 20,
    namespace: "tahi_#{Rails.env}"
  }
end
