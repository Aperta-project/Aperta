# YAML is part of the Ruby standard library and it is used here to convert
# "['server1', 'server2', 'server3']" into ['server1', 'server2', 'server3']
require 'yaml'
sentinels = YAML::load(ENV['REDIS_SENTINELS'])
Sidekiq.configure_server do |config|
  if sentinels.present?
    sentinel_list = sentinels.map do |sentinel_host|
      { host: sentinel_host, port: ENV['REDIS_PORT'] }
    end
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
  if sentinels.present?
    sentinel_list = sentinels.map do |sentinel_host|
      { host: sentinel_host, port: ENV['REDIS_PORT'] }
    end
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
