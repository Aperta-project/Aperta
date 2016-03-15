# Lock thread usage to a constant value.
thread_count = Integer(ENV.fetch 'MAX_THREADS', 16)
threads thread_count, thread_count

preload_app!

rackup DefaultRackup

pidfile File.join(Dir.pwd, 'tmp', 'pids', 'puma.pid')
state_path File.join(Dir.pwd, 'tmp', 'pids', 'puma.state')

stdout_redirect File.join(Dir.pwd, 'log', 'puma_access.log'),
                File.join(Dir.pwd, 'log', 'puma_error.log'),
                true

bind File.join("unix://#{Dir.pwd}", 'tmp', 'sockets', 'puma.sock')

activate_control_app File.join("unix://#{Dir.pwd}", 'tmp', 'sockets', 'pumactl.sock')

workers Integer(ENV.fetch 'PUMA_WORKERS', 3)

preload_app!

on_restart do
  ENV["BUNDLE_GEMFILE"] = "#{Dir.pwd}/Gemfile"
end

on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    ar_config = ActiveRecord::Base.configurations[Rails.env]
    ar_config['pool'] = thread_count
    ActiveRecord::Base.establish_connection(ar_config)
  end
end
