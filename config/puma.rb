workers Integer(ENV.fetch 'PUMA_WORKERS', 3)
# Lock thread usage to a constant value.
thread_count = Integer(ENV.fetch 'MAX_THREADS', 16)
threads thread_count, thread_count

preload_app!

port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    ar_config = ActiveRecord::Base.configurations[Rails.env]
    ar_config['pool'] = thread_count
    ActiveRecord::Base.establish_connection(ar_config)
  end

  Rails.logger.info "Puma Worker started with THREADS=#{thread_count}"
end
