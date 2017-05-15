workers Integer(ENV.fetch 'PUMA_WORKERS', 3)
# Lock thread usage to a constant value.
thread_count = Integer(ENV.fetch 'MAX_THREADS', 16)
threads thread_count, thread_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    ar_config = ActiveRecord::Base.configurations[Rails.env]
    ar_config['pool'] = thread_count
    # The line below will run all queries as unprepared_statements since by default
    # Rails and Postgres will run all queries as prepared statements. The large queries
    # associated with R&P may adversely affect memory usage on the database server if run as
    # a prepared statement. Assuming that many of these R&P calls will be relatively unique
    # per user, we are trading off increased available memory for not much benefit if we use
    # prepared statements so we are disabling prepared statements.
    # The Rails Guides mention to disable prepared statements to save on memory:
    # http://edgeguides.rubyonrails.org/configuring.html
    # Issue links: https://github.com/rails/rails/issues/14645
    #              https://github.com/rails/rails/issues/21992
    # Potential fix in Rails 5:
    #              https://github.com/rails/rails/commit/cbcdecd2c55fca9613722779231de2d8dd67ad02
    ar_config['prepared_statements'] = false
    ActiveRecord::Base.establish_connection(ar_config)
  end

  Rails.logger.info "Puma Worker started with THREADS=#{thread_count}"
end
