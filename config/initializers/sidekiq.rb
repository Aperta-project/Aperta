Sidekiq.configure_server do |config|
  config.redis = {
    namespace: "tahi_#{Rails.env}"
  }

  # allow configuration of concurrency without redeploy
  # controls the number of redis connections
  sidekiq_workers = Integer(ENV['SIDEKIQ_CONCURRENCY'] || 25)
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
    namespace: "tahi_#{Rails.env}"
  }
end
